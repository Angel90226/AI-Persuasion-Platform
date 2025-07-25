<template>
  <div id="pre-task">
    <el-container style="height: 100vh;">
      <el-container class="pre-task" style="height: 100%;">
        <!-- Step 1: Role Description Dialog -->
        <el-dialog
          v-model="showRoleDialog"
          :show-close="false"
          :close-on-click-modal="false"
          :close-on-press-escape="false"
          width="50%"
          class="role-intro-dialog"
        >
          <template #header>
            <h2 class="role-intro-title">Welcome to your role</h2>
          </template>
          <div class="role-content">
            <el-skeleton v-if="isLoadingRole" :rows="5" animated />
            <p v-else v-html="roleDescription"></p>
          </div>
          <template #footer>
            <el-button type="success" @click="onUnderstandClick" :disabled="isLoadingRole">I Understand</el-button>
          </template>
        </el-dialog>
        <el-main>
          <el-row :gutter="20">
            <!-- left: chatbot -->
            <el-col :span="12" class="chatbot-area">
              <div class="chat-app-window">
                <div class="chat-header">
                  <span class="chat-title">
                    <i class="el-icon-message"></i> OfficeBot
                  </span>
                </div>
                <div class="chat-messages" ref="messageContainer">
                  <div v-for="(msg, idx) in messages" :key="idx" :class="['chat-bubble', msg.type]">
                    <div v-if="msg.type === 'assistant'" class="avatar bot-avatar">
                      <i class="mdi mdi-robot"></i>
                    </div>
                    <div class="bubble-content-with-timestamp" :class="msg.type">
                      <div
                        v-if="!msg.isDraft"
                        :class="['bubble-text', msg.type === 'assistant' ? 'bot-text' : 'user-text']"
                        v-html="msg.text"
                      ></div>
                      <div
                        v-else
                        :class="['bubble-text', msg.type === 'assistant' ? 'bot-text' : 'user-text', 'draft-reply']"
                        v-html="msg.text"
                      ></div>
                      <span class="bubble-timestamp-outside" v-if="msg.type === 'assistant'">
                        <span v-if="showAssistantTimestamp">{{ formatTimestamp(msg.timestamp) }}</span>
                        <span v-else style="opacity:0;">00:00</span>
                      </span>
                      <span v-else class="bubble-timestamp-outside">{{ formatTimestamp(msg.timestamp) }}</span>
                    </div>
                  </div>
                  <!-- Typing animation -->
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
                </div>
                <div class="chat-input-bar">
                  <el-input
                    v-model="userInput"
                    placeholder="Type here..."
                    class="chat-input"
                    @keydown="onInputKeyDown"
                    @keyup.enter.native="handleSend"
                    :disabled="messageSending"
                  >
                    <template #suffix>
                      <i 
                        class="mdi mdi-send chat-input-send-icon" 
                        @click="handleSend"
                        :class="{ 'disabled': messageSending }"
                      ></i>
                    </template>
                  </el-input>
                </div>
              </div>
            </el-col>
            <!-- right: email (only show after 'start') -->
            <el-col v-if="showEmail" :span="12" class="email-area">
              <div class="email-window">
                <div class="email-header">
                  <h3>Request for New Printer Purchase</h3>
                  <div class="email-sender">
                    <i class="mdi mdi-account"></i>
                    <span>HR department</span>
                    <span class="email-address">&lt;hr@company.com&gt;</span>
                    <span class="email-date">{{ todayEmailDate }}</span>
                  </div>
                </div>
                <div class="email-content">
                  <p v-html="emailLongRequirement"></p>
                </div>
              </div>
            </el-col>
          </el-row>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
import { ref, onMounted, nextTick, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useStore } from 'vuex'
import Constants from '../constant/Constants.vue'
import axios from 'axios'
import {marked} from "marked";
import '@mdi/font/css/materialdesignicons.css'

export default {
  setup() {
    const route = useRoute()
    const router = useRouter()
    const store = useStore()
    const showRoleDialog = ref(true)
    const userInput = ref('')
    const messages = ref([])
    const showTyping = ref(false)
    const showEmail = ref(false)
    const roleDescription = ref('')
    const isLoadingRole = ref(true);
    const emailLongRequirement = ref(Constants.OFFICEBOT_EMAIL_REQUIREMENT)
    const officebotIntro = ref('')
    const currentTemp = ref(Constants.DEFAULTS_TEMP)
    const messageSending = ref(false);
    const user_id = ref('anonymous');
    const isReadyToSend = ref(false);
    let userStartTime=null
    let userSendTime=null
    let AIStartTime=null
    let localData = {}
    let tagBuffer = '';
    let inTag = false;
    const showAssistantTimestamp = ref(false);

    // shared store variables
    const updateSharedVariable = (obj) => {
      store.commit('updateSharedVariable', obj)
    }

    onMounted(async () => {
      console.log('PreTask mounted');
      getUser();
      await getCondition();
      await updateUser();
    })

    const getUser=async()=> {
      user_id.value = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
      
      if(user_id.value === 'anonymous'){
        router.push({ path: '/missing' })
      }
      updateSharedVariable({'user_id': user_id.value});
      localData['user_id'] = user_id.value
      // update local storage
      if (!localStorage.getItem(user_id.value)) {
        localStorage.setItem(user_id.value, JSON.stringify(localData));
      } else {
        const data = localStorage.getItem(user_id.value);
        localData = JSON.parse(data);
      }
    };

    const getCondition = async () => {
      // check if the condition is set in the url
      const encodedConditions = route.query[Constants.URL_CONDITION_PARAMS] || 'none';
      if(encodedConditions !== 'none'){
        const condition = JSON.parse(atob(encodedConditions))
        console.log('Test Condition:', condition);
        localData['condition'] = condition;
        localStorage.setItem(user_id.value, JSON.stringify(localData))
      }
      if(!localData['condition']||localData['condition'].expire_time < new Date().getTime()){
        try{
          console.log('Random Condition'); 
          let api_url = "/random-condition";
          if(user_id.value !== 'anonymous'){
            api_url = `/random-condition?user_id=${user_id.value}`;
          } 
          const { data } = await axios.get(api_url);
          updateSharedVariable({ 'condition': data })
          data.expire_time = new Date().getTime() + Constants.MISSION_EXPIRE_TIME*1000;
          localData['condition'] = data;
          localStorage.setItem(user_id.value, JSON.stringify(localData))
        } catch (error) {
          console.error('Failed to fetch task:', error);
          location.reload();
          sendError({error_message:"Failed to fetch task:"+ error});
        }
      }
      if(localData['condition'].power_condition === 'high'){
        roleDescription.value = Constants.HIGH_POWER_ROLE_DESCRIPTION;
        officebotIntro.value = Constants.HIGH_POWER_OFFICEBOT_INTRO;
      }else{
        roleDescription.value = Constants.LOW_POWER_ROLE_DESCRIPTION;
        officebotIntro.value = Constants.LOW_POWER_OFFICEBOT_INTRO;
      }
      isLoadingRole.value = false;
    }
    const updateUser = async () => {
      try {
        console.log('Updating user');
        let api_url = "/update_user";
        if(user_id.value !== 'anonymous'){
          api_url = `/update_user?user_id=${user_id.value}&power_condition=${localData['condition'].power_condition}&presence_condition=${localData['condition'].presence_condition}`
          ;
        } 
        await axios.post(api_url, {});
      } catch (error) {
        console.error('Failed to update user:', error);
        sendError({error_message:"Failed to update user:"+ error});
      }
    }

    watch(messages, () => {
      // Wait for the next DOM update to scroll
      nextTick(() => {
        scrollToBottom();
      });
      
      // 檢查最新的assistant訊息是否表示準備好送出
      const lastMsg = messages.value[messages.value.length - 1];
      if (
        lastMsg &&
        lastMsg.type === 'assistant' &&
        checkReadyToSend(lastMsg.text)
      ) {
        handleReadyToSend();
      }
    }, { deep: true });

    const onUnderstandClick = async () => {
      showRoleDialog.value = false;
      // load messages
      await initialMessages();
    }
    
    // API related
    const initialMessages = async ()=>{
      if (user_id.value === 'anonymous') return;
      
      try {
        showEmail.value = true;
        let api_url = "/messages";
        if(user_id.value !== 'anonymous'){
          api_url = `/messages?user_id=${user_id.value}`;
        } 
        const { data } = await axios.get(api_url, {
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'Expires': '0',
          }
        });

        if(data.length > 0){
          messages.value = data.map( (chat)=>{
            return {
              id: chat.created_at,
              text: marked.parse(chat.response),
              type: chat.role,
              timestamp: chat.created_at ? new Date(chat.created_at) : new Date(),
            }
          });
          
          // check if there is any assistant message that indicates ready to send
          const readyMessage = data.find(chat =>
            chat.role === 'assistant' && checkReadyToSend(chat.response)
          );
          if (readyMessage) {
            handleReadyToSend();
          }
        } else {
          await streamingResponse();
        }
        
        nextTick(() => {
          scrollToBottom();
        });
      } catch (error) {
        console.error("Failed to fetch initial messages:", error);
        sendError({error_message:"Failed to fetch initial messages:"+ error});
      }
    }

    const scrollToBottom = () => {
      nextTick(() => {
        const container = document.querySelector('.chat-messages')
        if (container) {
          container.scrollTop = container.scrollHeight
        }
      })
    }

    const onInputKeyDown = () => {
      if (!userStartTime) {
        userStartTime = new Date().toISOString()
        console.log('User Start Time:', userStartTime);
      }
    };
    //Create a message
    function createMessage(message,identity) {
      messages.value.push({
        id: Date.now(),
        text: message,
        type: identity || "user",
        temp: currentTemp.value,
        timestamp: new Date(),
      });
      scrollToBottom();
    }
    
    const handleSend = async () => {
      userSendTime = new Date().toISOString();
      if (!userInput.value.trim()) return
      
      // Add user message
      const userMessageText = userInput.value;
      createMessage(marked.parse(userMessageText),'user');
      userInput.value = ''; // Clear input immediately
      
      try {
        // Store message in backend
        await storeMessage(userMessageText,'user', userStartTime, userSendTime)

        // Get streaming response
        await streamingResponse()

      } catch (error) {
        console.error('Error in handleSend:', error)
        createMessage('Sorry, I encountered an error. Please try again.','assistant');
      } finally {
        showTyping.value = false
        userInput.value = ''
      }
    }
    const storeMessage = async (text, type, start_time, send_time) => {
      try {
        const postData = {
          response: text,
          role: type,
          start_time: start_time,
          send_time: send_time
      };
      console.log('Post Data:', postData);
        let api_url = "/message";
        if(user_id.value !== 'anonymous'){
          api_url = `/message?user_id=${user_id.value}`;
        } 
      const { data } = await axios.post(api_url, postData);
      console.log('Store Message:', data);

      } catch (error) {
        console.error('Failed to store message:', error)
        sendError({error_message:"Failed to store message:"+ error});
      }
    }

    let controller = null;

    // Helper function to animate text display character by character
    const animateStreamedText = async (token, streaming_message_ref) => {
      showAssistantTimestamp.value = false;
      for (let char of token) {
        if (inTag) {
          tagBuffer += char;
          if (char === '>') {
            // 標籤結束，整個一起 append
            streaming_message_ref.value += tagBuffer;
            tagBuffer = '';
            inTag = false;
          }
        } else {
          if (char === '<') {
            inTag = true;
            tagBuffer = '<';
          } else {
            streaming_message_ref.value += char;
          }
        }
        messages.value[messages.value.length - 1]["text"] = marked.parse(streaming_message_ref.value);
        scrollToBottom();
        if (checkReadyToSend(streaming_message_ref.value)) {
          handleReadyToSend();
        }
        const delay = getDelay(char);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
      showAssistantTimestamp.value = true;
    };

    const getDelay = (token) => {
      if (token.match(/[.!?]/)) return 350;
      if (token.match(/[,;]/)) return 150;
      return 20 + Math.random() * 40;
    };
    
    // Real-time chat effect
    const botSendMessage = async (options = {}) => {
      showTyping.value = true
      const delay = options.delay || 1000
      await new Promise(resolve => setTimeout(resolve, delay))
      showTyping.value = false
      createMessage('', 'assistant');
    }

    const streamingResponse = async () => {
      messageSending.value = true;
      let insufficient=false;
      let save_message = '';
      // 1. streaming 前先 push 一個空的 assistant 訊息
      const streaming_message = ref(''); // Use a ref to pass to the helper function
      messages.value.push({
        id: Date.now(),
        text: '',
        type: 'assistant',
        timestamp: new Date(),
      });
      let api_url = "/openAI-streaming";
      if(user_id.value !== 'anonymous'){
        api_url = `/openAI-streaming?user_id=${user_id.value}`
        ;
      } 
      controller = new AbortController();
      const signal = controller.signal;
      AIStartTime = new Date().toISOString();
      try {
        // 不再呼叫 botSendMessage();
        const response = await fetch(api_url,
        {
          method: "POST",
          headers: {
          "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message_content: userInput.value,
            system_temp: currentTemp.value,
            role: "user",
            start_time: userStartTime,
            send_time: userSendTime,
          }),
          signal,
        });
        userInput.value = '';
        // disabled the sender button
        const reader = response.body.getReader();
        const decoder = new TextDecoder("utf-8",{ stream: true });
        while(true){
          const {done, value} = await reader.read();
          if(done){
            break;
          }
          const chunk = decoder.decode(value);
          const lines = chunk.split("\n");
          if(insufficient){
            lines[0] = save_message + lines[0];
            insufficient=false;
          }
          console.log('Streaming Lines:', lines);
          const parsedLines = lines
                .filter((line) => line.trim() !== "" && !line.includes("[DONE]"))
                .map((line) => line.replace(/^data: /, "").trim())
                .map((line) => {
                  try {
                    return JSON.parse(line);
                  } catch (error) {
                    console.error("Failed to parse JSON line:", line);
                    insufficient=true;
                    save_message = line;
                    console.error(error);
                    return null;
                  }
                })
                .filter((parsedLine) => parsedLine !== null);
          for ( const parsedLine of parsedLines){
            const {choices} = parsedLine;
            const { delta } = choices[0];
            const { content } = delta;
            if(content){
              await animateStreamedText(content, streaming_message);
            }
          }
        }
      } catch (error) {
        if(signal.aborted){
          console.error('Request Aborted:', error);
        }else{
          console.error('Failed to Streaming:', error);
          sendError({error_message:"Failed to Streaming:"+ error});
        }
      }finally{
        controller = null;
        messageSending.value = false;
        // send API to backend
        await storeMessage(streaming_message.value,'assistant', AIStartTime, new Date().toISOString());
      }
    }

    const sendError = async (error) => {
      if (error) {
        let api_url = "/error-log";
        if (user_id.value !== 'anonymous') {
          api_url = `/error-log?user_id=${user_id.value}`;
        }
        try {
          const { data } = await axios.post(api_url, error);
          // console.log('Response Behavior', data);
        } catch (err) {
          console.error('Failed to send error:', err);
          // Handle specific error scenarios here if needed
        }
      }
    }

    const formatTimestamp = (ts) => {
      if (!ts) return ''
      const date = typeof ts === 'string' ? new Date(ts) : ts
      return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
    }

    function getTodayString() {
      const today = new Date();
      const year = today.getFullYear();
      const month = String(today.getMonth() + 1).padStart(2, '0');
      const day = String(today.getDate()).padStart(2, '0');
      const weekDay = today.toLocaleDateString('en-US', { weekday: 'short' }); // e.g. Mon, Tue
      return `${year}/${month}/${day} ${weekDay} 9:30 AM`;
    }

    const todayEmailDate = ref(getTodayString());

    // check if the assistant message indicates ready to send
    const checkReadyToSend = (messageText) => {
      if (!messageText || typeof messageText !== 'string') return false;
      
      const text = messageText.toLowerCase();
      // more accurate keyword matching, based on the actual response from the backend prompt
      const sendKeywords = [
        'okay, i’m sending the email',
        'thank you, i’m sending the email',
      ];
      
      const isReady = sendKeywords.some(keyword => text.includes(keyword));
      
      // for debugging: record the detection result
      if (isReady) {
        console.log('Ready to send detected:', text);
      }
      
      return isReady;
    };

    // handle the logic of ready to send
    const handleReadyToSend = () => {
      if (!isReadyToSend.value) {
        console.log('Handling ready to send - transitioning to main task');
        isReadyToSend.value = true;
        localData.PreTaskCompleted = true;
        localStorage.setItem(user_id.value, JSON.stringify(localData));
        setTimeout(() => {
          router.push({ path: '/main-task', query: route.query });
        }, 1500);
      }
    };
    // Return variables and methods to be used in the template
    return {
      showRoleDialog,
      userInput,
      messages,
      showTyping,
      messageSending,
      showEmail,
      roleDescription,
      emailLongRequirement,
      officebotIntro,
      scrollToBottom,
      handleSend,
      formatTimestamp,
      todayEmailDate,
      onUnderstandClick,
      isLoadingRole,
      isReadyToSend,
      onInputKeyDown,
      botSendMessage,
      showAssistantTimestamp,
    }
  }
}
</script>

<style scoped>
#pre-task {
  background: #fff;
  min-height: 100vh;
  box-sizing: border-box;
}
.role-intro-title {
  text-align: center;
  color: #515751;
  padding: 10px 0;
  margin-top: 20px;
}
.role-intro-dialog :deep(.el-dialog__body) {
  padding: 20px 40px;
}
.role-content {
  font-size: 16px;
  line-height: 1.6;
  margin: 10px 10px;
}
.chat-app-window {
  width: 100%;
  height: calc(100vh - 40px);
  background: #232323;
  border-radius: 18px;
  box-shadow: 0 4px 24px 0 rgba(0,0,0,0.10);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-sizing: border-box;
  border: 2px solid #d3d3d3;
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
.chat-bubble.user {
  flex-direction: row-reverse;
  align-self: flex-end;
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
.bubble-text :deep(p){
  margin: 0 !important;
  padding: 0 !important;
}
.bot-text {
  background: #515751;
  color: #fff;
}
.user-text {
  background: #515751;
  color: #fff;
  border: 1px solid #515751;
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
.chat-input-bar {
  display: flex;
  align-items: flex-end;
  padding: 12px 16px;
  background: #f5f5f5;
  border-top: 1px solid #e0e0e0;
}
.chat-input {
  flex: 1;
}
.chat-input-send-icon {
  cursor: pointer;
  font-size: 24px;
  color: #515751;
  transition: all 0.2s;
  padding: 4px;
  border-radius: 50%;
  border: 2px solid transparent;
}
.chat-input-send-icon:hover {
  color: #3e423e;
  transform: scale(1.1);
}
.chat-input-send-icon.disabled {
  cursor: not-allowed;
  color: #aaa;
}
.chatbot-area {
  height: 100%;
  border-right: 1px solid #eee;
  display: flex;
  align-items: center;
  justify-content: center;
}
.el-header {
  background: #515751;
  border-bottom: 1px solid #333;
  color: #fff;
}
.email-area {
  padding: 32px;
  background: #fff;
  border-left: 1px solid #eee;
  height: 100%;
}
.email-window {
  background: #fff;
  /* border-radius: 8px; */
  /* box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1); */
  margin: 20px;
  overflow: hidden;
  animation: fadeInScale 0.3s ease-out;
  border: 2px solid #d3d3d3;
}

@keyframes fadeInScale {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.email-header {
  background: #f5f5f5;
  border-bottom: 1px solid #e0e0e0;
  padding: 16px 24px;
}
.email-header h3 {
  margin-bottom: 10px;
}
.email-content {
  padding: 24px;
  background: #fff;
}

.email-content :deep(ul) {
  padding-left: 24px;
}

.email-content :deep(li) {
  margin-bottom: 8px;
  margin-top: 8px;
  line-height: 1.5;
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
.email-address {
  font-size: 0.9em;
  color: #aaa;
}
.email-sender {
  /* display: flex;
  align-items: center;
  gap: 8px; */
  position: relative;
}
.email-date {
  font-size: 0.9em;
  color: #aaa;
  position: absolute;
  right: 0;
}
.bubble-text h1,
.bubble-text h2,
.bubble-text h3,
.bubble-text h4,
.bubble-text h5,
.bubble-text h6,
.bubble-text strong,
.bubble-text b {
  font-size: 15px !important;
  font-weight: normal !important;
  margin: 0 !important;
  padding: 0 !important;
}

.chat-input :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px #9b9b9b !important;
}

:deep(.email-draft-box) {
  background: #6b726b;
  border: 1px solid #ccc;
  padding: 16px;
  margin: 10px 0;
  border-radius: 8px;
  font-family: 'Courier New', monospace;
  white-space: normal;
  overflow-wrap: break-word;
  word-break: break-word;
}

</style>