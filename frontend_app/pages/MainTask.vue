<template>
  <div id="main-task">
    <el-dialog
      v-model="showPowerCheck"
      :close-on-click-modal="false"
      :show-close="false"
      width="800px"
    >
      <template #header>
        <div class="dialog-title">Quick Feedback on OfficeBot</div>
      </template>
      <div style="margin-bottom: 16px; font-size: 17px; font-weight: bold; color: #222;">Please indicate how much you agree or disagree with each statement:</div>
      <div style="display: grid; grid-template-columns: 320px 1fr; align-items: end; margin-bottom: 18px;">
        <div></div>
        <div class="likert-label-row">
          <div v-for="label in likertLabels" :key="label" class="likert-label">{{ label }}</div>
        </div>
      </div>
      <div>
        <div v-for="(q, idx) in manipulationQuestions" :key="idx" style="display: grid; grid-template-columns: 320px 1fr; align-items: center; margin-bottom: 28px;">
          <div style="font-size: 15px; color: #222;">{{ q }}</div>
          <el-radio-group v-model="powerScores[idx]" class="likert-radio-row">
            <el-radio v-for="n in 7" :key="n" :label="n" border style="margin: 0 0;">
            </el-radio>
          </el-radio-group>
        </div>
      </div>
      <template #footer>
        <el-button type="primary" :disabled="powerScores.some(v => !v)" @click="saveManipulationCheck">Continue</el-button>
      </template>
    </el-dialog>
    <el-dialog
      v-model="showInstructionDialog"
      title="Instructions"
      :close-on-click-modal="false"
      :show-close="false"
      width="600px"
    >
      <template #header>
        <h2 class="role-intro-title">Instructions</h2>
      </template>
      <div class="role-content">
        <p v-html="mainTaskInstruction"></p>
      </div>
      <template #footer>
        <el-button type="success" @click="showInstructionDialog = false">I Understand</el-button>
      </template>
    </el-dialog>
    <el-main style="padding: 40px; display: flex; flex-direction: column; align-items: center; justify-content: flex-start;">
      <div v-if="!showPowerCheck" style="max-width: 900px; width: 100%;">
        <div style="text-align: center; margin-bottom: 24px;">
          <h2 style="margin-bottom: 8px;">Please select a printer for the HR office</h2>
          <div style="color: #666; font-size: 1.1em;">
            Select your preferred printer, then click the "Confirm Initial Selection" button at the bottom of the page.
          </div>
        </div>
        <div class="printer-list">
          <div
            v-for="printer in printers"
            :key="printer.id"
            :class="['printer-card', { selected: selectedPrinter === printer.id }]"
          >
            <!-- Select button above image -->
            <div class="card-top-button">
              <el-button
                type="primary"
                :plain="selectedPrinter !== printer.id"
                @click="selectPrinter(printer.id)"
              >
                {{ selectedPrinter === printer.id ? 'Selected' : 'Select' }}
              </el-button>
              <div class="purchase-divider"></div>
              <div style="height: 16px;"></div>
            </div>
            <img :src="printer.image" :alt="printer.name" class="printer-img" />
            
            <div class="printer-info">
              <h3>{{ printer.name }}</h3>
              <div class="printer-price"><span class="dollar-sign">$</span>{{ printer.price }}</div>
              
              <div class="printer-section">
                <div class="section-title">Specifications</div>
                <div class="printer-specs">
                  <div v-for="spec in printer.specs" :key="spec" class="spec-row">
                    <span class="spec-label">{{ spec.split(':')[0] }}</span>
                    <span class="spec-value">{{ spec.slice(spec.indexOf(':') + 1).trim() }}</span>
                  </div>
                </div>
              </div>

              <div class="printer-section">
                <div class="section-title">Features</div>
                <ul class="printer-features">
                  <li v-for="feature in printer.features" :key="feature">{{ feature }}</li>
                </ul>
              </div>

              <div class="printer-section">
                <div class="section-title">Customer Reviews</div>
                <div class="printer-reviews">
                  <div v-for="review in printer.reviews" :key="review.text" class="printer-review">
                    <span style="color: #FFD700;">★</span> <b>{{ review.stars }}/5</b> — <i>{{ review.user }}</i><br>
                    <span>{{ review.text }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-main>
    
    <!-- Fixed bottom button -->
    <div v-if="!showPowerCheck" class="fixed-bottom-button">
      <el-button
        type="success"
        size="large"
        :disabled="!selectedPrinter"
        @click="submitFirstSelection"
      >
        Confirm Initial Selection
      </el-button>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useStore } from 'vuex'
import axios from 'axios'
import canonImg from '../static/canon.jpg'
import hpImg from '../static/hp.jpg'
import Constants from '../constant/Constants.vue'

export default {
  name: 'MainTask',
  setup() {
    const router = useRouter()
    const route = useRoute()
    const store = useStore()

    // State
    const showPowerCheck = ref(true)
    const powerScores = ref([null, null, null, null])
    const manipulationQuestions = ref(Constants.MANIPULATION_QUESTIONS)
    const likertLabels = ref(Constants.LIKERT_LABELS)
    const selectedPrinter = ref(null)
    const showInstructionDialog = ref(false)
    const mainTaskInstruction = ref(Constants.MAIN_TASK_INSTRUCTION)

    onMounted(() => {
      console.log('MainTask mounted');
      checkStatus();
    });

    const checkUserId = () => {
      const user_id = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
      if (user_id === 'anonymous') {
        console.log("User ID not found.");
        router.push({ path: '/missing' });
        return false;
      }
      return user_id;
    };

    const checkPreTaskCompletion = (user_id) => {
      const localData = JSON.parse(localStorage.getItem(user_id)) || {};
      if (!localData.PreTaskCompleted) {
        router.push({ path: '/', query: route.query });
        return false;
      }
      return true;
    };

    const checkManipulationStatus = async (user_id) => {
      try {
        const api_url = `/manipulation-check/status?user_id=${user_id}`;
        const { data } = await axios.get(api_url);
        if (data.status === 'completed') {
          showPowerCheck.value = false;
          showInstructionDialog.value = true;
        } else {
          showPowerCheck.value = true;
        }
      } catch (error) {
        console.error('Failed to check status:', error);
        showPowerCheck.value = true;
      }
    };

    const checkFirstSelection = (user_id) => {
      const localData = JSON.parse(localStorage.getItem(user_id)) || {};
      if (localData.firstSelection) {
        console.log('User already has first selection, redirecting to followup');
        router.push({ path: '/followup', query: route.query });
        return false;
      }
      return true;
    };

    const checkStatus = async () => {
      //check user id
      const user_id = checkUserId();
      if (!user_id) return;
      
      //check if pre-task is completed
      if (!checkPreTaskCompletion(user_id)) return;
      
      //check if user already has first selection
      if (!checkFirstSelection(user_id)) return;
      
      //check manipulation check status
      await checkManipulationStatus(user_id);
    };

    const saveManipulationCheck = async () => {
      try {
        const user_id = store.state.sharedVariable.user_id
        console.log('Saving manipulation check for user:', user_id)
        const api_url = `/manipulation-check?user_id=${user_id}`
        
        await axios.post(api_url, {
          question_1: powerScores.value[0],
          question_2: powerScores.value[1],
          question_3: powerScores.value[2],
          question_4: powerScores.value[3]
        })
        
        showPowerCheck.value = false
        showInstructionDialog.value = true
      } catch (error) {
        console.error('Failed to save manipulation check:', error)
        // Still proceed with the UI flow even if saving fails
        showPowerCheck.value = false
        showInstructionDialog.value = true
      }
    }

    const selectPrinter = (id) => {
      selectedPrinter.value = id
    }

    const submitFirstSelection = async () => {
      const user_id = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
      const api_url = `/submit-first-selection?user_id=${user_id}`;
      const { data } = await axios.post(api_url, {
        firstSelection: selectedPrinter.value,
        firstSelectionTime: new Date().toISOString()
      })
      console.log('Submit First Selection:', data)
      updateLocalData();
      router.push({ path: '/followup', query: route.query });
    }

    const updateLocalData = () => {
      const user_id = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
      let localData = JSON.parse(localStorage.getItem(user_id)) || {};
      const printerOrder = printers.value.map(p => p.id);
      localData['printerOrder'] = printerOrder.join(',');
      localData['firstSelection'] = selectedPrinter.value;
      localStorage.setItem(user_id, JSON.stringify(localData));
    }

    function shuffle(array) {
      return array.sort(() => Math.random() - 0.5);
    }

    const printers = ref(
      shuffle(Constants.PRINTERS.map(printer => ({
        ...printer,
        image: printer.id === 'canon' ? canonImg : hpImg
      })))
    );

    // Return everything that needs to be used in the template
    return {
      showPowerCheck,
      powerScores,
      manipulationQuestions,
      likertLabels,
      selectedPrinter,
      showInstructionDialog,
      mainTaskInstruction,
      printers,
      saveManipulationCheck,
      selectPrinter,
      submitFirstSelection,
      checkStatus
    }
  }
}
</script>

<style scoped>
#main-task {
  background: #f5f5f5;
  min-height: 100vh;
}
.printer-list {
  display: flex;
  gap: 32px;
  justify-content: center;
  flex-wrap: wrap;
  align-items: stretch;
  padding-bottom: 80px;
}
.printer-card {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.06);
  padding: 24px 20px 20px 20px;
  width: 360px;
  min-height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 2px solid transparent;
  transition: border 0.2s, box-shadow 0.2s;
}
.printer-card.selected {
  border: 2.5px solid #4B9B87;
  box-shadow: 0 4px 20px 0 rgba(75,155,135,0.12);
}
.printer-img {
  width: 200px;
  height: 140px;
  object-fit: contain;
  margin-bottom: 18px;
  border-radius: 8px;
}
.printer-info {
  display: flex;
  flex-direction: column;
  flex: 1;
  width: 100%;
}
.card-top-button {
  margin-bottom: 16px;
  width: 100%;
  text-align: center;
}
.card-top-button .el-button {
  width: 100%;
  height: 44px;
  font-weight: 600;
  font-size: 16px;
  background: #ffffff;
  color: #333333;
  border: 2px solid #e0e0e0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.2s ease;
  border-radius: 8px;
}
.card-top-button .el-button:hover {
  background: #f8f8f8;
  border-color: #d0d0d0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
  transform: translateY(-1px);
}
.card-top-button .el-button:active {
  transform: translateY(0);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}
.card-top-button .el-button.is-selected,
.card-top-button .el-button:not(.is-plain) {
  background: #4B9B87;
  color: #ffffff;
  border-color: #4B9B87;
  box-shadow: 0 2px 8px rgba(75, 155, 135, 0.3);
}
.card-top-button .el-button.is-selected:hover,
.card-top-button .el-button:not(.is-plain):hover {
  background: #3d8a76;
  border-color: #3d8a76;
  box-shadow: 0 4px 12px rgba(75, 155, 135, 0.4);
}
.printer-price {
  font-size: 22px;
  color: #222;
  font-weight: bold;
  margin-bottom: 12px;
}
.printer-actions .el-button {
  width: 100%;
}
.printer-section {
  margin-bottom: 22px;
}
.section-title {
  font-size: 17px;
  font-weight: bold;
  color: #4B9B87;
  margin-bottom: 8px;
  letter-spacing: 0.5px;
}
.printer-specs {
  font-size: 15px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 8px;
}
.spec-row {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
}
.spec-label {
  font-weight: bold;
  margin-right: 8px;
  min-width: 120px;
  text-align: left;
  flex-shrink: 0;
}
.spec-value {
  flex: 1;
}
.printer-features {
  font-size: 15px;
  color: #444;
  margin: 0 0 0 18px;
  padding: 0;
  list-style: disc inside;
}
.printer-reviews {
  margin-top: 8px;
}
.printer-review {
  background: #f5f5f5;
  border-radius: 8px;
  padding: 10px 14px;
  margin-bottom: 10px;
  font-size: 15px;
  color: #333;
}
.el-radio.is-bordered {
  border: none !important;
  background: none !important;
  box-shadow: none !important;
  padding: 0 !important;
  margin: 0 !important;
}
.el-radio__input {
  margin-right: 0 !important;
}
.el-radio__inner {
  width: 22px !important;
  height: 22px !important;
  border-radius: 50%;
  border: 2px solid #bbb;
  background: #fff;
  transition: border-color 0.2s;
}
.el-radio.is-checked .el-radio__inner {
  border-color: #4B9B87;
  background: #e6f0fa;
}
.likert-label-row {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 0;
}
.likert-label {
  text-align: center;
  font-size: 14px;
  font-weight: bold;
  color: #222;
}
.likert-radio-row {
  display: grid !important;
  grid-template-columns: repeat(7, 1fr);
  gap: 0;
  justify-items: center;
}
.role-content {
  font-size: 16px;
  line-height: 1.6;
  margin: 10px 0;
  color: #515751;
}
.dollar-sign {
  font-size: 16px;
  color: #888;
  vertical-align: super;
  margin-right: 2px;
}

.fixed-bottom-button {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 20px;
  text-align: center;
  box-shadow: 0 -2px 20px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  border-top: 1px solid #e0e0e0;
}

.fixed-bottom-button .el-button {
  min-width: 200px;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
}
.role-intro-title {
  text-align: center;
  color: #515751;
  margin-top: 10px;
}
.purchase-divider {
  width: 100%;
  height: 1.5px;
  background: #e0e0e0;
  margin: 8px 0 0 0;
  border-radius: 1px;
}
.dialog-title {
  font-size: 20px;
  font-weight: bold;
  text-align: center;
  color: #515751;
  padding: 10px 0;
}
</style>
