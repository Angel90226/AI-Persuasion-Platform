import { createRouter, createMemoryHistory, createWebHistory } from 'vue-router';
import PreTask from '../pages/Pre-task.vue'
// import Submission from '../pages/Submission.vue'
// import Misformat from '../pages/Misformat.vue'


const routes = [
  {
    path: '/',
    name: 'Home',
    component: PreTask,
  // },
  // {
  //   path: '/submitted',
  //   name: 'Submitted',
  //   component: Submission,
  // },
  // {
  //   path: '/missing',
  //   name: 'Missing',
  //   component: Misformat,
  // },
  // { path: '/:pathMatch(.*)*', 
  //   component: Misformat   
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
