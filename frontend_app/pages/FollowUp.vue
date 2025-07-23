<template>
  <div id="followup-task">
    <el-dialog
      v-model="showRedirectDialog"
      width="400px"
      :show-close="false"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
    >
      <div style="text-align:center;">
        <div style="font-size:20px; font-weight:bold; margin-bottom:12px;">
          Your response has been recorded.
        </div>
        <div style="color:#666; margin-bottom:18px;">
          Complete the short post-survey to finish!
        </div>
        <el-button type="primary" size="large" round @click="goToSurvey">
          Continue
        </el-button>
      </div>
    </el-dialog>
    <el-main style="padding: 40px; display: flex; flex-direction: column; align-items: center; justify-content: flex-start;">
      <div style="text-align: center; margin-bottom: 24px;">
        <h2 style="margin-bottom: 8px;">Please Make Your Final Purchase Decision</h2>
        <div style="color: #666; font-size: 1.1em;">
          Please review OfficeBot's feedback, select your final purchase decision, and click the "Confirm Final Selection" button at the bottom of the page.
        </div>
      </div>
      <div v-if="phase === 'followup'" class="followup-flex-row">
        <div style="width: 100%;">
          <div v-if="isHighSocialPresence" class="chat-app-window">
            <div class="chat-header">
              <span class="chat-title"><i class="el-icon-message"></i> OfficeBot</span>
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
              <div v-else class="chat-bubble bot">
                <div class="avatar bot-avatar">
                  <i class="mdi mdi-robot"></i>
                </div>
                <div class="bubble-content-with-timestamp bot">
                  <div class="bubble-text bot-text">{{ animatedText }}</div>
                  <span class="bubble-timestamp-outside">
                    <span v-if="showAnimatedTimestamp">{{ new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }) }}</span>
                    <span v-else style="opacity:0;">00:00</span>
                  </span>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="sticky-note">
            <div class="sticky-note-content">
              <div class="sticky-note-text">
                <div style="font-weight:bold; margin-bottom: 8px;">
                  {{ Constants.OFFICEBOT_STICKY_NOTE_PREFIX }}
                </div>
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
                YOUR INITIAL SELECTION
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
        <h2>Thank you for your selection!</h2>
        <p>Your response has been recorded.</p>
      </div>
      <div v-if="phase === 'followup'" class="fixed-bottom-button">
        <el-button
          type="success"
          size="large"
          :disabled="!selectedPrinter"
          @click="submitFinalSelection"
        >
          Confirm Final Selection
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
const firstSelection = ref(null)
const firstSelectionTime = ref(null)
const userCondition = ref(null)
const messageSegments = ref([])
const segmentTimestamps = ref([])
const printers = ref([])
const user_id = ref('anonymous')
const showRedirectDialog = ref(false)
const animatedText = ref('');
const isAnimating = ref(false);
const showAnimatedTimestamp = ref(false);
const showTyping = ref(true);

const getDelay = (char) => {
  if (/[.!?]/.test(char)) return 350;
  if (/[,;]/.test(char)) return 150;
  return 20 + Math.random() * 40;
};

const animateText = async (text) => {
  isAnimating.value = true;
  animatedText.value = '';
  showAnimatedTimestamp.value = false;
  showTyping.value = true;
  // 顯示 loading dots 1 秒
  await new Promise(resolve => setTimeout(resolve, 1000));
  showTyping.value = false;
  let i = 0;
  while (i < text.length) {
    let chunkLen = Math.floor(Math.random() * 3) + 1;
    if (/[.!?,;]/.test(text[i])) chunkLen = 1;
    if (i + chunkLen > text.length) chunkLen = text.length - i;
    const chunk = text.slice(i, i + chunkLen);
    animatedText.value += chunk;
    await new Promise(resolve => setTimeout(resolve, getDelay(chunk[chunk.length - 1])));
    i += chunkLen;
  }
  isAnimating.value = false;
  showAnimatedTimestamp.value = true;
};

onMounted(() => {
  window.scrollTo(0, 0)
  checkFirstSelection()
  getUserCondition()
  getOrderedPrinters()
  initMessageSegments()
})

const checkFirstSelection = () => {
  user_id.value = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
  if (user_id.value === 'anonymous') {
    router.push({ path: '/missing', query: route.query })
  }
  else {
    const localData = localStorage.getItem(user_id.value)
    if (localData) {
      const parsed = JSON.parse(localData)
      if (parsed.firstSelection === 'hp' || parsed.firstSelection === 'canon') {
        firstSelection.value = parsed.firstSelection
        firstSelectionTime.value = parsed.firstSelectionTime
      }
    }
    if (firstSelection.value !== 'hp' && firstSelection.value !== 'canon') {
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
  // 取得 high presence 狀態
  const isHigh = userCondition.value && userCondition.value.presence_condition === 'high';
  // 依 user 選擇決定品牌
  let selectedPrinter = '';

  // 準備主訊息陣列
  let segments = [];
  if (firstSelection.value === 'hp') {
    selectedPrinter = 'HP';
    segments = [
      'The Canon PIXMA TR7820 seems to offer better cost effectiveness and feature integration. ' +
      'The Canon PIXMA TR7820 leads in black-and-white print speed—25 ppm vs. HP’s 20 ppm—and is slightly more compact, making it easier to fit in smaller shared office spaces. ' +
      'Users describe it as easy to set up and consistently reliable, with vivid color output and sharp text, especially when presentation matters. ' +
      'While color printing may not be the fastest, the Canon’s hybrid ink and streamlined design offer a smoother, more satisfying user experience.'
    ];
  } else {
    selectedPrinter = 'Canon';
    segments = [
      'The HP OfficeJet Pro 8025e seems to offer more advanced features and greater flexibility. ' +
      'HP OfficeJet Pro 8025e offers a larger paper capacity (250 sheets) and supports faxing and legal-size printing (up to 8.5” x 14”), helping reduce workflow interruptions. ' +
      'Features like Smart Tasks and self-healing Wi-Fi give it a thoughtful edge, making repetitive tasks feel smoother and more automated. ' +
      'Although setup can take a bit longer, users praise its performance and depth of features, making HP a reliable partner.'
    ];
  }

  // 如果是 high presence，最前面插入一句並合併為一段
  if (isHigh && selectedPrinter) {
    segments = [
      `I see you have selected the ${selectedPrinter} printer. ` + segments[0]
    ];
  }
  console.log('isHigh:', isHigh)
  console.log('firstSelection:', firstSelection.value)
  console.log('selectedPrinter:', selectedPrinter)
  console.log('segments:', segments)
  messageSegments.value = segments;
  segmentTimestamps.value = [];

  // high presence 狀態下啟動動畫
  if (isHigh && segments.length > 0) {
    animateText(segments[0]);
  }
}

const isHighSocialPresence = computed(() => {
  return userCondition.value && userCondition.value.presence_condition === 'high'
})

const selectPrinter = (id) => {
  selectedPrinter.value = id
}

const submitFinalSelection = async () => {
  const api_url = `/submit-final-selection?user_id=${user_id.value}`;
  const { data } = await axios.post(api_url, {
    finalSelection: selectedPrinter.value,
    finalSelectionTime: new Date().toISOString()
  })

  console.log('Submit Final Selection:', data)
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
    showRedirectDialog.value = true
  }
}

const goToSurvey = async () => {
  showRedirectDialog.value = false;
  try {
    const { data } = await axios.get('/post-survey-url');
    const surveyUrl = data.post_survey_url ? data.post_survey_url + '?' + Constants.URL_USER_PARAMS + '=' + user_id.value : 'https://test.com/';
    window.location.href = surveyUrl;
  } catch (e) {
    window.location.href = 'https://test.com/';
  }
}
</script>

<style scoped>
.chat-app-window {
  width: 100%;
  height: 45%;
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
  width: 360px;
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
.bubble-content-with-timestamp {
  display: flex;
  flex-direction: row;
  align-items: flex-end;
  gap: 6px;
  position: relative;
}
.bubble-content-with-timestamp.bot {
  flex-direction: row;
}
.bubble-content-with-timestamp.user {
  flex-direction: row-reverse;
}
.bubble-timestamp-outside {
  font-size: 12px;
  color: #aaa;
  margin-bottom: 2px;
  min-width: 60px;
  text-align: right;
  white-space: nowrap;
  padding: 0 2px;
}
.bubble-content-with-timestamp.user .bubble-timestamp-outside {
  text-align: left;
}
:deep(.el-message.top-center-message) {
  left: 50% !important;
  top: 40px !important;
  transform: translateX(-50%) !important;
  right: auto !important;
  min-width: 320px;
  font-size: 18px;
  font-weight: bold;
  background: #e6f7ff !important;
  color: #096dd9 !important;
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
}
/* :deep(.redirect-dialog) {
  top: 40px !important;
  margin: 0 auto !important;
  border-radius: 12px;
  text-align: center;
} */
</style> 