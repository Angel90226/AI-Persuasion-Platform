<template>
  <div id="followup-task">
    <el-main style="padding: 40px; display: flex; flex-direction: column; align-items: center; justify-content: flex-start;">
      <div v-if="phase === 'followup'" class="followup-flex-row">
        <div style="width: 100%;">
          <div v-if="isHighSocialPresence" class="chat-app-window">
            <div class="chat-header">
              <span class="chat-title"><i class="el-icon-message"></i> NaviBot</span>
            </div>
            <div class="chat-messages" style="height: 320px;">
              <div v-if="showTyping" class="chat-bubble bot">
                <div class="avatar bot-avatar">
                  <i class="mdi mdi-robot"></i>
                </div>
                <div class="bubble-content">
                  <div class="bubble-text bot-text typing">
                    <span class="dot"></span><span class="dot"></span><span class="dot"></span>
                  </div>
                </div>
              </div>
              <template v-else>
                <div v-for="(seg, idx) in messageSegments.slice(0, currentStep)" :key="idx" class="chat-bubble bot">
                  <div v-if="idx === 0" class="avatar bot-avatar">
                    <i class="mdi mdi-robot"></i>
                  </div>
                  <div v-else style="width:36px;min-width:36px;max-width:36px;"></div>
                  <div class="bubble-content">
                    <div class="bubble-text bot-text">{{ seg }}</div>
                  </div>
                </div>
              </template>
            </div>
          </div>
          <div v-else class="sticky-note">
            <div class="sticky-note-content">
              <div class="sticky-note-text">
                {{ messageSegments.join(' ') }}
              </div>
            </div>
          </div>
        </div>
        <template v-for="printer in printers" :key="printer.id">
          <div class="printer-col">
            <div :class="['printer-card', { selected: selectedPrinter === printer.id }]">
              <div class="card-top-button">
                <el-button
                  type="primary"
                  :plain="selectedPrinter !== printer.id"
                  @click="selectPrinter(printer.id)"
                >
                  {{ selectedPrinter === printer.id ? 'Selected' : 'Purchase' }}
                </el-button>
                <div class="purchase-divider"></div>
                <div style="height: 16px;"></div>
              </div>
              <div
                v-if="printer.id === firstSelection"
                class="preference-label"
              >
                YOUR PREFERENCE
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
        </template>
      </div>
      <div v-else-if="phase === 'final'" style="max-width: 900px; width: 100%; text-align: center;">
        <h2>Thank you for your choice!</h2>
        <p>Your response has been recorded.</p>
      </div>
      <div v-if="phase === 'followup'" class="fixed-bottom-button">
        <el-button
          type="success"
          size="large"
          :disabled="!selectedPrinter"
          @click="submitFinalChoice"
        >
          Confirm Final Choice
        </el-button>
      </div>
    </el-main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import canonImg from '../static/canon.jpg'
import hpImg from '../static/hp.jpg'
import Constants from '../constant/Constants.vue'
import axios from 'axios'

const route = useRoute()
const router = useRouter()

const phase = ref('followup')
const selectedPrinter = ref(null)
const showTyping = ref(true)
const currentStep = ref(0)
const firstSelection = ref(null)
const firstSelectionTime = ref(null)
const userCondition = ref(null)
const messageSegments = ref([])
const printers = ref([])
const user_id = ref('anonymous')

onMounted(() => {
  window.scrollTo(0, 0)
  checkFirstSelection()
  getUserCondition()
  getOrderedPrinters()
  initMessageSegments()
  setTimeout(() => {
    setupInitialMessages()
  }, 1200)
})

const checkFirstSelection = () => {
  user_id.value = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
  if (user_id.value === 'anonymous') {
    router.push({ path: '/missing', query: route.query })
  }
  else {
    const localData = localStorage.getItem(user_id.value)
    console.log('localData', localData)
    if (localData) {
      firstSelection.value = JSON.parse(localData).firstSelection
      firstSelectionTime.value = JSON.parse(localData).firstSelectionTime
    }
    if (firstSelection.value === null) {
      router.push({ path: '/', query: route.query })
    }
  }
}

const getUserCondition = () => {
  if (user_id.value !== 'anonymous') {
    const localData = localStorage.getItem(user_id.value)
    if (localData) {
      const parsedData = JSON.parse(localData)
      userCondition.value = parsedData.condition
    }
  }
}

const getOrderedPrinters = () => {
  printers.value = [...Constants.PRINTERS];
  const localData = JSON.parse(localStorage.getItem(user_id.value)) || {};
  if (localData.printerOrder) {
    const order = localData.printerOrder.split(',');
    printers.value.sort((a, b) => order.indexOf(a.id) - order.indexOf(b.id));
  }
  // 替換圖片來源
  printers.value = printers.value.map(printer => ({
    ...printer,
    image: printer.id === 'canon' ? canonImg : hpImg
  }));
}

const initMessageSegments = () => {
  if (firstSelection.value === 'hp') {
    messageSegments.value = [
      `Although the HP OfficeJet Pro 8025e is a cost-effective option, the Canon PIXMA TR7820 offers more advanced features that may better support your team's needs.`,
      `It prints at up to 15 pages per minute in black and 10 in color, includes a 2.7" LCD touchscreen for easier control, and supports both borderless and auto-duplex printing.`,
      `While it weighs slightly less (16 lbs vs. 18 lbs), the added functionality and performance may justify the higher price if efficiency and output quality are priorities.`
    ]
  } else {
    messageSegments.value = [
      `While the Canon PIXMA TR7820 provides a range of all-in-one functions, the HP OfficeJet Pro 8025e may be a more practical and budget-friendly choice.`,
      `It offers a larger paper tray (225 sheets vs. 100 sheets), faster black-and-white print speeds (20 ppm vs. 15 ppm), and costs nearly half as much ($${printers.value.find(p => p.id === 'hp').price} vs. $${printers.value.find(p => p.id === 'canon').price}).`,
      `If your team values high-volume printing and smart productivity features like Smart Tasks and self-healing Wi-Fi, the HP could be the smarter pick.`
    ]
  }
}

const isHighSocialPresence = computed(() => {
  return userCondition.value && userCondition.value.presence_condition === 'high'
})

const setupInitialMessages = () => {
  showTyping.value = false
  currentStep.value = 1
  revealNextSegment()
}

const selectPrinter = (id) => {
  selectedPrinter.value = id
}

const submitFinalChoice = async () => {
  const api_url = `/submit-final-choice?user_id=${user_id.value}`;
  const { data } = await axios.post(api_url, {
    finalSelection: selectedPrinter.value,
    finalSelectionTime: new Date().toISOString()
  })

  console.log('Submit Final Choice:', data)
  taskFinished()
}

const taskFinished = async () => {
  const api_url = `/task-finished?user_id=${user_id.value}`;
  const { data } = await axios.get(api_url, {
    params: {
      conditions: JSON.parse(localStorage.getItem(user_id.value)).condition
    }
  })
  if (data.taskFinished) {
    phase.value = 'final'
    ElMessage.success('Thank you for your final choice!')
  }
}


const revealNextSegment = () => {
  if (currentStep.value < messageSegments.value.length) {
    setTimeout(() => {
      currentStep.value++
      revealNextSegment()
    }, 1400)
  }
}
</script>

<style scoped>
.chat-app-window {
  width: 100%;
  height: 380px;
  background: #fff;
  border-radius: 18px;
  box-shadow: 0 4px 24px 0 rgba(0,0,0,0.10);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.chat-header {
  height: 54px;
  background: #515751;
  color: #fff;
  display: flex;
  align-items: center;
  padding: 0 20px;
  font-weight: bold;
  font-size: 18px;
  letter-spacing: 1px;
}
.chat-title {
  display: flex;
  align-items: center;
  gap: 8px;
}
.chat-messages {
  flex: 1;
  padding: 20px 16px 12px 16px;
  overflow-y: auto;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.chat-bubble {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  max-width: 80%;
  flex-shrink: 0;
}
.chat-bubble.bot {
  flex-direction: row;
  align-self: flex-start;
}
.avatar {
  width: 40px;
  height: 40px;
  min-width: 40px;
  min-height: 40px;
  max-width: 40px;
  max-height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #515751;
  overflow: hidden;
  position: relative;
}
.avatar i {
  font-size: 24px;
  color: #fff;
  position: relative;
  top: -1px;
}
.bubble-content {
  flex: 1 1 auto;
  min-width: 0;
}
.bubble-text {
  border-radius: 16px;
  padding: 12px 18px;
  font-size: 15px;
  word-break: break-word;
  box-shadow: 0 1px 4px 0 rgba(0,0,0,0.04);
}
.bot-text {
  background: #515751;
  color: #fff;
}
.printer-list {
  display: flex;
  gap: 32px;
  justify-content: center;
  flex-wrap: wrap;
  align-items: stretch;
}
.printer-card {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.06);
  padding: 24px 20px 20px 20px;
  width: 340px;
  min-height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 2px solid transparent;
  transition: border 0.2s, box-shadow 0.2s;
  position: relative;
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
.printer-col {
  flex: 1 1 0;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.typing {
  display: flex;
  align-items: center;
  gap: 2px;
  min-width: 36px;
  background: #515751;
  color: #fff;
}
.dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  margin: 0 2px;
  background: #fff;
  border-radius: 50%;
  animation: blink 1.2s infinite both;
}
.dot:nth-child(2) {
  animation-delay: 0.2s;
}
.dot:nth-child(3) {
  animation-delay: 0.4s;
}
@keyframes blink {
  0%, 80%, 100% { opacity: 0.2; }
  40% { opacity: 1; }
}

.printer-bottom {
  margin-top: auto;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: stretch;
  gap: 8px;
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
.dollar-sign {
  font-size: 16px;
  color: #888;
  vertical-align: super;
  margin-right: 2px;
}
.sticky-note {
  width: 100%;
  height: 340px;
  background: #fff86b;
  border: 1px solid #e6e600;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 0 24px 0;
  box-shadow: -4px 4px 8px 0px rgba(0,0,0,0.5);
}
.sticky-note-text {
  font-size: 18px;
  color: #333;
  text-align: center;
  word-break: break-word;
  padding: 16px;
}
.followup-flex-row {
  width: 100%;
  display: flex;
  flex-direction: row;
  gap: 32px;
  align-items: stretch;
  justify-content: center;
  padding-bottom: 80px;
}
.stamp-img-badge {
  position: absolute;
  top: 48px;
  left: 50%;
  transform: translateX(-50%) rotate(-8deg);
  pointer-events: none;
  z-index: 20;
  width: 160px;
  height: 80px;
}
.stamp-img {
  width: 200px;
  height: 200px;
  opacity: 0.7;
  position: absolute;
  top: 10%; left: -20%;
  pointer-events: none;
  /* filter: invert(18%) sepia(98%) saturate(7492%) hue-rotate(190deg) brightness(98%) contrast(119%); */
}
.stamp-text {
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%) rotate(-8deg);
  color: #d32f2f;
  font-family: 'Impact', 'Arial Black', Arial, sans-serif;
  font-size: 22px;
  font-weight: bold;
  text-transform: uppercase;
  letter-spacing: 2px;
  text-align: center;
  line-height: 1.1;
  pointer-events: none;
  width: 100%;
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
.preference-label {
  position: absolute;
  top: 85px;
  left: -5px;
  background: #0b28e1;
  color: #fff;
  padding: 6px 18px;
  border-radius: 0 6px 6px 0;
  font-size: 15px;
  font-weight: bold;
  letter-spacing: 1px;
  text-transform: uppercase;
  box-shadow: 0 2px 8px rgba(0,0,0,0.10);
  z-index: 10;
  pointer-events: none;
  user-select: none;
}
.purchase-divider {
  width: 100%;
  height: 1.5px;
  background: #e0e0e0;
  margin: 8px 0 0 0;
  border-radius: 1px;
}
</style> 