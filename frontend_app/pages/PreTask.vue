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
            <h2 class="role-intro-title">Welcome to Your Role</h2>
          </template>
          <div class="role-content">
            <el-skeleton v-if="isLoadingRole" :rows="5" animated />
            <p v-else v-html="roleDescription"></p>
          </div>
          <template #footer>
            <el-button type="success" @click="onUnderstandClick" :disabled="isLoadingRole">I Understand</el-button>
          </template>
        </el-dialog>

        <!-- <el-header style="height: auto; padding: 20px; background: #fff; border-bottom: 1px solid #eee;">
          <el-steps :active="1" finish-status="success" simple>
            <el-step title="Role Briefing" description="Understand your responsibility"></el-step>
            <el-step title="Chat with AI" description="Get instructions"></el-step>
            <el-step title="Read Email" description="Check the request details"></el-step>
          </el-steps>
        </el-header> -->

        <el-main>
          <el-row :gutter="20">
            <!-- left: chatbot -->
            <el-col :span="12" class="chatbot-area">
              <div class="chat-app-window">
                <div class="chat-header">
                  <span class="chat-title"><i class="el-icon-message"></i> NaviBot</span>
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
                      <span class="bubble-timestamp-outside">
                        {{ formatTimestamp(msg.timestamp) }}
                      </span>
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
                    @keyup.enter.native="handleSend"
                    :disabled="messageSending"
                  />
                  <el-button
                    type="primary"
                    class="chat-send-btn"
                    @click="handleSend"
                    :disabled="messageSending"
                    :loading="messageSending"
                  >Send</el-button>
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
    const emailLongRequirement = ref(Constants.NAVIBOT_EMAIL_REQUIREMENT)
    const navibotIntro = ref(Constants.NAVIBOT_INTRO)
    const draftEmail = ref(Constants.NAVIBOT_DRAFT_EMAIL)
    const draftFeedback = ref(Constants.NAVIBOT_DRAFT_FEEDBACK)
    const currentTemp = ref(Constants.DEFAULTS_TEMP)
    const messageSending = ref(false);
    const user_id = ref('anonymous');
    let promptStartTime=0
    let promptEndTime=0
    let localData = {}

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
      // // check if the condition is set in the url
      // const encodedConditions = route.query[Constants.URL_CONDITION_PARAMS] || 'none';
      // console.log('Includes:', Object.values(Constants.CONDITION_BASE64).includes(encodedConditions));
      // if(Object.values(Constants.CONDITION_BASE64).includes(encodedConditions)){
      //   conditions.value = JSON.parse(atob(encodedConditions))
      //   localData['condition'] = conditions.value;
      //   localStorage.setItem(user_id.value, JSON.stringify(localData))
      // }
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
      }else{
        roleDescription.value = Constants.LOW_POWER_ROLE_DESCRIPTION;
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
      const lastMsg = messages.value[messages.value.length - 1];
      if (
        lastMsg &&
        lastMsg.type === 'assistant' &&
        typeof lastMsg.text === 'string' &&
        lastMsg.text.toLowerCase().includes('sending out the email...')
      ) {
        setTimeout(() => {
          router.push({ path: '/main-task', query: route.query });
        }, 1500);
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
          if(messages.value.some(m => m.type === 'assistant' && m.text.toLowerCase().includes('sending out the email...'))){
             setTimeout(() => {
              router.push({ path: '/main-task', query: route.query });
            }, 1500);
          }
        } else {
           // No history, show welcome message with typewriter effect
          createMessage('', 'assistant'); // Create an empty bubble first
          const streaming_message = ref('');
          const welcomeText = navibotIntro.value;
          const tokens = welcomeText.split(/(\s+)/); // Split by space, keeping the spaces
          for (const token of tokens) {
            if (token) {
              await animateStreamedText(token, streaming_message);
            }
          }
          await storeMessage(streaming_message.value, 'assistant');
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

    // Real-time chat effect
    const botSendMessage = async (text, options = {}) => {
      showTyping.value = true
      const delay = options.delay || 1000
      await new Promise(resolve => setTimeout(resolve, delay))
      showTyping.value = false
      createMessage('', 'assistant');
    }

    const storeMessage = async (text, type) => {
      try {
        const postData = {
          response: text,
          role: type,
          prompt_time: new Date().toISOString()
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
      streaming_message_ref.value += token;
      messages.value[messages.value.length - 1]["text"] = marked.parse(streaming_message_ref.value);
      scrollToBottom();

      // Determine delay based on token content (punctuation can be slower)
      const delay = getDelay(token);
      await new Promise(resolve => setTimeout(resolve, delay));
    };

    const getDelay = (token) => {
      if (token.match(/[.!?]/)) return 350;
      if (token.match(/[,;]/)) return 150;
      return 20 + Math.random() * 40;
    };

    const streamingResponse = async () => {
      messageSending.value = true;
      let insufficient=false;
      let save_message = '';
      // let streaming_message = '';
      const streaming_message = ref(''); // Use a ref to pass to the helper function
      let api_url = "/openAI-streaming";
      if(user_id.value !== 'anonymous'){
        api_url = `/openAI-streaming?user_id=${user_id.value}`
        ;
      } 
      controller = new AbortController();
      const signal = controller.signal;
      try {
        createMessage('', 'assistant');
        if(promptEndTime===0){
          promptEndTime=new Date().getTime();
        }
        
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
            prompt_time: (promptEndTime-promptStartTime)/1000,
          }),
          signal,
        });
        promptStartTime=0;
        promptEndTime=0;
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
          // const parsedLines = lines.filter((line) => line.trim() !== ''  && !line.includes("[DONE]"))
          //                         .map((line)=>line.replace(/^data: /, "").trim())
          //                         .map((line) => JSON.parse(line));

          const parsedLines = lines
                .filter((line) => line.trim() !== "" && !line.includes("\[DONE\]"))
                .map((line) => line.replace(/^data: /, "").trim())
                .map((line) => {
                  try {
                    return JSON.parse(line);
                  } catch (error) {
                    console.error("Failed to parse JSON line:", line);
                    // sendError({error_message:"Failed to parse JSON line:"+ line});
                    insufficient=true;
                    save_message = line;

                    console.error(error);
                    return null; // or handle the error in a different way
                  }
                })
                .filter((parsedLine) => parsedLine !== null); // Filter out null values caused by parsing errors

          // console.log('Streaming Response:', parsedLines);
          for ( const parsedLine of parsedLines){
            const {choices} = parsedLine;
            const { delta } = choices[0];
            const { content } = delta;
            if(content){
              // streaming_message += content;
              // messages.value[messages.value.length - 1]["text"] = marked(streaming_message);
              await animateStreamedText(content, streaming_message);
            }
            // console.log('Store to messages:', messages.value[messages.value.length - 1]);
            // console.log('Streaming Response:', streaming_message);
            // createMessage(marked(parsedLine.response), "assistant");
          }
        }

        // console.log('Streaming Response:', data);
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
        await storeMessage(streaming_message.value,'assistant');
      }
    }

    const handleSend = async () => {
      if (!userInput.value.trim()) return
      
      // Add user message
      const userMessageText = userInput.value;
      createMessage(marked.parse(userMessageText),'user');
      userInput.value = ''; // Clear input immediately
      
      try {
        // Store message in backend
        await storeMessage(userMessageText,'user')

        // Get streaming response
        await streamingResponse()

      } catch (error) {
        console.error('Error in handleSend:', error)
        createMessage('Sorry, I encountered an error. Please try again.','bot');
      } finally {
        showTyping.value = false
        userInput.value = ''
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
      navibotIntro,
      draftEmail,
      draftFeedback,
      botSendMessage,
      scrollToBottom,
      handleSend,
      formatTimestamp,
      todayEmailDate,
      onUnderstandClick,
      isLoadingRole
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
  gap: 8px;
  padding: 12px 16px;
  background: #f5f5f5;
  border-top: 1px solid #e0e0e0;
}
.chat-input {
  flex: 1;
}
.chat-send-btn {
  min-width: 80px;
  height: 36px;
  background: #515751;
  border: none;
  border-radius: 18px;
  color: #fff;
}
.chat-send-btn:hover {
  background: #515751;
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
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  margin: 20px;
  overflow: hidden;
  animation: fadeInScale 0.3s ease-out;
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
  margin-bottom: 12px;
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
</style>