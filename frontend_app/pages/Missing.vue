<template>
  <div class="missing-page">
    <div class="content">
      <h1>URL is not valid</h1>
      <p>Sorry, this URL is not valid. Please make sure you accessed this page through the correct link.</p>
      <p>If you believe this is an error, please contact the study administrator.</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Missing'
}
</script>

<style scoped>
.missing-page {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
}

.content {
  text-align: center;
  padding: 2rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  max-width: 500px;
}

h1 {
  color: #333;
  margin-bottom: 1rem;
}

p {
  color: #666;
  line-height: 1.6;
  margin: 0.5rem 0;
}
</style>
