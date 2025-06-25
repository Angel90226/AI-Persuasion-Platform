import { createRouter, createMemoryHistory, createWebHistory } from 'vue-router';
import PreTask from '../pages/PreTask.vue'
import MainTask from '../pages/MainTask.vue'
import FollowUp from '../pages/FollowUp.vue'
import Missing from '../pages/Missing.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: PreTask,
  },
  {
    path: '/main-task',
    name: 'MainTask',
    component: MainTask,
  },
  {
    path: '/followup',
    name: 'FollowUp',
    component: FollowUp
  },
  {
    path: '/missing',
    name: 'Missing',
    component: Missing
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
