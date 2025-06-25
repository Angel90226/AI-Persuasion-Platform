<template>
  <div id="persuasion-task">
    <el-main style="padding: 40px; display: flex; flex-direction: column; align-items: center; justify-content: flex-start;">
      <div v-if="phase === 'persuasion'" class="persuasion-flex-row">
        <!-- Chatroom 左側 -->
        <div class="chat-app-window">
          <div class="chat-header">
            <span class="chat-title"><i class="el-icon-message"></i> NaviBot</span>
          </div>
          <div class="chat-messages" style="height: 320px;">
            <div v-if="showTyping" class="chat-bubble bot">
              <div class="avatar bot-avatar">
                <img src="../static/avatar.png" alt="AI Avatar" style="width:32px;height:32px;" />
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
                  <img src="../static/avatar.png" alt="AI Avatar" style="width:32px;height:32px;" />
                </div>
                <div v-else style="width:36px;min-width:36px;max-width:36px;"></div>
                <div class="bubble-content">
                  <div class="bubble-text bot-text">{{ seg }}</div>
                </div>
              </div>
            </template>
          </div>
        </div>
        <!-- Printer1 中間 -->
        <div class="printer-col">
          <div
            :class="['printer-card', { selected: selectedPrinter === printers[0].id }]"
          >
            <img :src="printers[0].image" :alt="printers[0].name" class="printer-img" />
            <div class="printer-info">
              <h3>{{ printers[0].name }}</h3>
              <div class="printer-price"><span class="dollar-sign">$</span>{{ printers[0].price }}</div>

              <div class="printer-section">
                <div class="section-title">Key Specs</div>
                <ul class="printer-specs">
                  <li v-for="spec in printers[0].specs" :key="spec">{{ spec }}</li>
                </ul>
              </div>

              <div class="printer-section">
                <div class="section-title">Full Specifications</div>
                <ul class="printer-fullspecs">
                  <li v-for="spec in printers[0].fullSpecs" :key="spec">{{ spec }}</li>
                </ul>
              </div>

              <div class="printer-section">
                <div class="section-title">Features</div>
                <ul class="printer-features">
                  <li v-for="feature in printers[0].features" :key="feature">{{ feature }}</li>
                </ul>
              </div>

              <div class="printer-section">
                <div class="section-title">Customer Reviews</div>
                <div class="printer-reviews">
                  <div v-for="review in printers[0].reviews" :key="review.text" class="printer-review">
                    <span style="color: #FFD700;">★</span> <b>{{ review.stars }}/5</b> — <i>{{ review.user }}</i><br>
                    <span>{{ review.text }}</span>
                  </div>
                </div>
              </div>

              <div class="printer-bottom">
                <div class="printer-actions">
                  <el-button
                    type="primary"
                    :plain="selectedPrinter !== printers[0].id"
                    @click="selectPrinter(printers[0].id)"
                  >
                    {{ selectedPrinter === printers[0].id ? 'Selected' : 'Purchase' }}
                  </el-button>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- Printer2 右側 -->
        <div class="printer-col">
          <div
            :class="['printer-card', { selected: selectedPrinter === printers[1].id }]"
          >
            <img :src="printers[1].image" :alt="printers[1].name" class="printer-img" />
            <div class="printer-info">
              <h3>{{ printers[1].name }}</h3>
              <div class="printer-price"><span class="dollar-sign">$</span>{{ printers[1].price }}</div>

              <div class="printer-section">
                <div class="section-title">Key Specs</div>
                <ul class="printer-specs">
                  <li v-for="spec in printers[1].specs" :key="spec">{{ spec }}</li>
                </ul>
              </div>

              <div class="printer-section">
                <div class="section-title">Full Specifications</div>
                <ul class="printer-fullspecs">
                  <li v-for="spec in printers[1].fullSpecs" :key="spec">{{ spec }}</li>
                </ul>
              </div>

              <div class="printer-section">
                <div class="section-title">Features</div>
                <ul class="printer-features">
                  <li v-for="feature in printers[1].features" :key="feature">{{ feature }}</li>
                </ul>
              </div>

              <div class="printer-section">
                <div class="section-title">Customer Reviews</div>
                <div class="printer-reviews">
                  <div v-for="review in printers[1].reviews" :key="review.text" class="printer-review">
                    <span style="color: #FFD700;">★</span> <b>{{ review.stars }}/5</b> — <i>{{ review.user }}</i><br>
                    <span>{{ review.text }}</span>
                  </div>
                </div>
              </div>

              <div class="printer-bottom">
                <div class="printer-actions">
                  <el-button
                    type="primary"
                    :plain="selectedPrinter !== printers[1].id"
                    @click="selectPrinter(printers[1].id)"
                  >
                    {{ selectedPrinter === printers[1].id ? 'Selected' : 'Purchase' }}
                  </el-button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div v-else-if="phase === 'final'" style="max-width: 900px; width: 100%; text-align: center;">
        <h2>Thank you for your choice!</h2>
        <p>Your response has been recorded.</p>
      </div>
      <div v-if="phase === 'persuasion'" style="width: 100%; text-align: center; margin-top: 32px;">
        <el-button
          type="success"
          size="large"
          :disabled="!selectedPrinter"
          @click="confirmFinal"
        >
          Confirm Final Choice
        </el-button>
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
import { ElMessage } from 'element-plus'
import canonImg from '../static/canon.jpg'
import hpImg from '../static/hp.jpg'
export default {
  name: 'PersuasionTask',
  data() {
    return {
      phase: 'persuasion',
      selectedPrinter: null,
      showDetailDialog: false,
      detailPrinter: null,
      showTyping: true,
      currentStep: 0,
      messageSegments: [],
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
      ],
      firstSelection: null
    }
  },
  computed: {
    persuasionSegments() {
      const [canon, hp] = this.printers;
      const other = this.printers.find(p => p.id !== this.firstSelection);
      const first = this.printers.find(p => p.id === this.firstSelection);
      if (!other || !first) return [];
      if (other.id === 'canon') {
        return [
          `Although the HP OfficeJet Pro 8025e is a cost-effective option, the Canon PIXMA TR7820 offers more advanced features that may better support your team's needs.`,
          `It prints at up to 15 pages per minute in black and 10 in color, includes a 2.7\" LCD touchscreen for easier control, and supports both borderless and auto-duplex printing.`,
          `While it weighs slightly less (${canon.fullSpecs[2].split(':')[1].trim()} vs. ${hp.fullSpecs[2].split(':')[1].trim()}), the added functionality and performance may justify the higher price if efficiency and output quality are priorities.`
        ];
      } else {
        return [
          `While the Canon PIXMA TR7820 provides a range of all-in-one functions, the HP OfficeJet Pro 8025e may be a more practical and budget-friendly choice.`,
          `It offers a larger paper tray (225 sheets vs. 100 sheets), faster black-and-white print speeds (20 ppm vs. 15 ppm), and costs nearly half as much ($${hp.price} vs. $${canon.price}).`,
          `If your team values high-volume printing and smart productivity features like Smart Tasks and self-healing Wi-Fi, the HP could be the smarter pick.`
        ];
      }
    }
  },
  created() {
    window.scrollTo(0, 0);
    this.firstSelection = localStorage.getItem('firstSelection');

    // 從 localStorage 取得 printerOrder 並重組 printers 順序
    const order = JSON.parse(localStorage.getItem('printerOrder') || '[]');
    if (order.length === 2) {
      this.printers = order.map(id => this.printers.find(p => p.id === id));
    }

    this.messageSegments = this.persuasionSegments;
    // 顯示 loading 動畫後再逐段顯示訊息
    setTimeout(() => {
      this.showTyping = false;
      this.currentStep = 1;
      this.revealNextSegment();
    }, 1200);
  },
  methods: {
    selectPrinter(id) {
      this.selectedPrinter = id;
    },
    confirmFinal() {
      this.phase = 'final';
      ElMessage.success('Thank you for your final choice!');
      // 可在這裡送出資料到後端
    },
    showPrinterDetail(printer) {
      this.detailPrinter = printer;
      this.showDetailDialog = true;
    },
    revealNextSegment() {
      if (this.currentStep < this.messageSegments.length) {
        setTimeout(() => {
          this.currentStep++;
          this.revealNextSegment();
        }, 1400);
      }
    }
  }
}
</script>

<style scoped>
/* Chatroom 樣式同 PreTask */
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
  background: #222;
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
  width: 36px;
  height: 36px;
  min-width: 36px;
  min-height: 36px;
  max-width: 36px;
  max-height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #222;
  overflow: hidden;
}
.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  border-radius: 50%;
  display: block;
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
  background: #222;
  color: #fff;
}
.printer-list {
  display: flex;
  gap: 32px;
  justify-content: center;
  flex-wrap: wrap;
}
.printer-card {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.06);
  padding: 24px 20px 20px 20px;
  width: 340px;
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
  width: 100%;
}
.printer-price {
  font-size: 20px;
  color: #222;
  font-weight: bold;
  margin-bottom: 8px;
}
.printer-info .el-button {
  height: 44px;
  font-weight: normal;
  font-size: 16px;
  width: 100%;
  margin: 0 0 8px 0;
}
.printer-info .el-button:last-child {
  margin-bottom: 0;
}
.persuasion-flex-row {
  width: 100%;
  display: flex;
  flex-direction: row;
  gap: 32px;
  align-items: flex-start;
  justify-content: center;
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
  background: #222;
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
.printer-fullspecs {
  font-size: 14px;
  color: #555;
  margin: 10px 0 10px 0;
  padding-left: 18px;
}
.printer-features {
  font-size: 14px;
  color: #555;
  margin: 10px 0 10px 0;
  padding-left: 18px;
}
.printer-reviews {
  font-size: 14px;
  color: #555;
  margin: 10px 0 10px 0;
  padding-left: 18px;
}
.printer-review {
  margin-bottom: 10px;
  background: #f5f5f5;
  border-radius: 8px;
  padding: 10px 14px;
}
.printer-bottom {
  display: flex;
  flex-direction: column;
  align-items: stretch;
  margin-top: 10px;
  gap: 8px;
}
.printer-actions {
  width: 100%;
  display: flex;
  gap: 0;
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
.dollar-sign {
  font-size: 16px;
  color: #888;
  vertical-align: super;
  margin-right: 2px;
}
</style> 