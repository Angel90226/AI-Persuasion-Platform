<template>
  <div id="main-task">
    <el-dialog
      v-model="showPowerCheck"
      title="Quick Question"
      :close-on-click-modal="false"
      :show-close="false"
      width="800px"
    >
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
        <el-button type="primary" :disabled="powerScores.some(v => !v)" @click="closePowerCheck">Continue</el-button>
      </template>
    </el-dialog>
    <el-dialog
      v-model="showInstructionDialog"
      title="Instructions"
      :close-on-click-modal="false"
      :show-close="false"
      width="480px"
    >
      <template #header>
        <h2>Instructions</h2>
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
        <h2 style="margin-bottom: 24px;">Please select a printer for your office</h2>
        <div class="printer-list">
          <div
            v-for="printer in printers"
            :key="printer.id"
            :class="['printer-card', { selected: selectedPrinter === printer.id }]"
          >
            <img :src="printer.image" :alt="printer.name" class="printer-img" />
            <div class="printer-info">
              <h3>{{ printer.name }}</h3>
              <div class="printer-price"><span class="dollar-sign">$</span>{{ printer.price }}</div>

              <div class="printer-section">
                <div class="section-title">Key Specs</div>
                <ul class="printer-specs">
                  <li v-for="spec in printer.specs" :key="spec">{{ spec }}</li>
                </ul>
              </div>

              <div class="printer-section">
                <div class="section-title">Full Specifications</div>
                <ul class="printer-fullspecs">
                  <li v-for="spec in printer.fullSpecs" :key="spec">{{ spec }}</li>
                </ul>
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

              <div class="printer-bottom">
                <div class="printer-actions">
                  <el-button
                    type="primary"
                    :plain="selectedPrinter !== printer.id"
                    @click="selectPrinter(printer.id)"
                  >
                    {{ selectedPrinter === printer.id ? 'Selected' : 'Select' }}
                  </el-button>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div style="text-align: center; margin-top: 32px;">
          <el-button
            type="success"
            size="large"
            :disabled="!selectedPrinter"
            @click="confirmSelection"
          >
            Confirm Selection
          </el-button>
        </div>
      </div>
    </el-main>
    <!-- Printer Detail Dialog -->
    <el-dialog
      v-model="showDetailDialog"
      :title="detailPrinter?.name"
      width="520px"
      :close-on-click-modal="true"
    >
      <div v-if="detailPrinter">
        <img :src="detailPrinter.image" :alt="detailPrinter.name" style="width: 260px; display: block; margin: 0 auto 18px auto; background: #f8f8f8; border-radius: 10px;" />
        <div style="font-size: 15px; color: #4B9B87; font-weight: bold; text-align: center; margin-bottom: 8px;">{{ detailPrinter.brand }}</div>
        <div style="font-size: 18px; color: #222; font-weight: bold; text-align: center; margin-bottom: 12px;">${{ detailPrinter.price }}</div>
        <ul style="font-size: 15px; color: #444; margin-bottom: 16px;">
          <li v-for="spec in detailPrinter.fullSpecs" :key="spec">{{ spec }}</li>
        </ul>
        <div style="margin-bottom: 16px;">
          <b>Features:</b>
          <ul style="margin: 6px 0 0 18px; color: #555;">
            <li v-for="feature in detailPrinter.features" :key="feature">{{ feature }}</li>
          </ul>
        </div>
        <div style="margin-bottom: 8px;">
          <b>Customer Reviews:</b>
          <div style="margin-top: 4px;">
            <div v-for="review in detailPrinter.reviews" :key="review.text" style="margin-bottom: 10px; background: #f5f5f5; border-radius: 8px; padding: 10px 14px;">
              <span style="color: #FFD700;">★</span> <b>{{ review.stars }}/5</b> — <i>{{ review.user }}</i><br>
              <span>{{ review.text }}</span>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="showDetailDialog = false">Close</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import canonImg from '../static/canon.jpg'
import hpImg from '../static/hp.jpg'
export default {
  name: 'MainTask',
  data() {
    return {
      showPowerCheck: true,
      powerScores: [null, null, null, null],
      manipulationQuestions: [
        'In my interactions with the AI agent, I felt I could get the AI agent to listen to what I say.',
        'In my interaction with the AI agent, if I want to, I get to make the decisions.',
        "My preferences didn't seem to carry much weight with the AI agent.",
        'I felt my ideas and opinions were often ignored by the AI agent.'
      ],
      likertLabels: [
        'Strongly Disagree',
        'Disagree',
        'Somewhat Disagree',
        'Either Agree or Disagree',
        'Somewhat Agree',
        'Agree',
        'Strongly Agree'
      ],
      selectedPrinter: null,
      showDetailDialog: false,
      detailPrinter: null,
      showInstructionDialog: false,
      mainTaskInstruction: `Based on the HR team's request, the AI agent has selected two printers for you to consider.<br>
<strong>Please review the options and choose the one you think is most suitable for the office.</strong>`,
      printers: [
        {
          id: 'canon',
          name: 'Canon PIXMA TR7820',
          brand: 'Canon',
          image: canonImg,
          price: 129.00,
          specs: [
            'All-in-One: Print, Copy, Scan',
            'Print Speed: 15 ppm (black), 10 ppm (color)',
            '2.7" LCD Touchscreen',
            'Auto-Duplex, Auto Document Feeder',
            'Wireless & USB',
            '100-sheet paper capacity',
            'Color: White'
          ],
          fullSpecs: [
            'Model: PIXMA TR7820',
            'Dimensions: 15.9 x 14.2 x 8.2 inches',
            'Weight: 16 lbs',
            'Max Print Size: 8.5" x 11"',
            'Print Resolution: Up to 4800 x 1200 dpi',
            'Connectivity: USB, Wireless',
            'Paper Capacity: 100 sheets (cassette), 100 sheets (rear tray)',
            'ADF: 35 sheets',
            'Display: 2.7" LCD Touchscreen',
            'Compatible OS: Windows, Mac, Mobile',
            'Warranty: 1 year'
          ],
          features: [
            'Easy setup and maintenance',
            'Hybrid ink system for sharp text and vivid photos',
            'Poster Artist Online for banners and signage',
            'Energy Star certified'
          ],
          reviews: [
            { user: 'Alice', stars: 5, text: 'Great print quality and easy to use!' },
            { user: 'Bob', stars: 4, text: 'Setup was quick, but color printing is a bit slow.' }
          ]
        },
        {
          id: 'hp',
          name: 'HP OfficeJet Pro 8025e',
          brand: 'HP',
          image: hpImg,
          price: 69.99,
          specs: [
            'All-in-One: Print, Copy, Scan, Fax',
            'Print Speed: 20 ppm (black), 10 ppm (color)',
            '2.7" Color Touchscreen',
            'Auto-Duplex, Auto Document Feeder',
            'Wireless, Ethernet, USB',
            '225-sheet input tray',
            'Color: Gray'
          ],
          fullSpecs: [
            'Model: OfficeJet Pro 8025e',
            'Dimensions: 18.1 x 20.1 x 9.2 inches',
            'Weight: 18 lbs',
            'Max Print Size: 8.5" x 14"',
            'Print Resolution: Up to 4800 x 1200 dpi',
            'Connectivity: USB, Wireless, Ethernet',
            'Paper Capacity: 225 sheets',
            'ADF: 35 sheets',
            'Display: 2.7" Color Touchscreen',
            'Compatible OS: Windows, Mac, Mobile',
            'Warranty: 1 year'
          ],
          features: [
            'Smart Tasks shortcuts for productivity',
            'Self-healing Wi-Fi',
            'HP+ Smart Printing System',
            'Energy Star certified'
          ],
          reviews: [
            { user: 'Carol', stars: 5, text: 'Fast printing and lots of features for the price.' },
            { user: 'David', stars: 4, text: 'Good value, but setup took a bit longer than expected.' }
          ]
        }
      ]
    }
  },
  methods: {
    closePowerCheck() {
      this.showPowerCheck = false;
      this.showInstructionDialog = true;
      // 之後可在這裡處理 powerScore 上傳或其他邏輯
    },
    selectPrinter(id) {
      this.selectedPrinter = id;
    },
    confirmSelection() {
      // 跳轉到 persuasion 階段 route，並帶上第一次選擇
      this.$router.push({ path: '/persuasion', query: { first: this.selectedPrinter } });
    },
    showPrinterDetail(printer) {
      this.detailPrinter = printer;
      this.showDetailDialog = true;
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
.printer-brand {
  font-size: 14px;
  color: #4B9B87;
  font-weight: bold;
  margin-bottom: 6px;
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
.printer-specs,
.printer-fullspecs,
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
  margin: 20px 0;
  color: #222;
}
.dollar-sign {
  font-size: 16px;
  color: #888;
  vertical-align: super;
  margin-right: 2px;
}
</style>
