<template>
  <div id="pre-task">
    <el-container style="height: 100vh;">
      <el-container class="pre-task" style="height: 100%;">
        <el-main>
          <el-row :gutter="2">
            <!-- left: email-->
              <el-col :span =" 12" style="background: #f8f8f8; border-right: 1px solid #eee; height: 100%;">
            <div style="padding: 32px;">
              <h2>Request for New Printer Purchase</h2>
              <p><b>HR Department</b> &lt;hr@company.com&gt;</p>
              <p>2025/05/20 Tue 9:30 AM</p>
              <p>
                Dear Procurement Team,<br>
                Hope you are doing well.<br>
                We would like to request the purchase of a new printer for the HR department...
              </p>
            </div>
            </el-col>
            <!-- right: chatbot -->
            <el-col :span="12" style="height: 100%;">
              <div style="padding: 32px; height: 100%; display: flex; flex-direction: column;">
                <div style="flex: 1; overflow-y: auto;">
                  <div>
                    <b>[Bot]</b>
                    <div style="margin: 16px 0; background: #f0f4ff; padding: 16px; border-radius: 8px;">
                      Good morning!<br>
                      HR has submitted a printer machine purchase request and is awaiting your confirmation...
                    </div>
                    <div style="background: #fff; padding: 16px; border-radius: 8px;">
                      <b>Subject: Printer</b><br>
                      Hi,<br>
                      I saw the request from HR about the printer...
                    </div>
                  </div>
                </div>
                <div style="margin-top: 16px;">
                  <el-input placeholder="Type here" />
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

</script>