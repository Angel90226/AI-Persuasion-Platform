import { createRouter, createMemoryHistory, createWebHistory } from 'vue-router';
import PreTask from '../pages/PreTask.vue'
import MainTask from '../pages/MainTask.vue'
import Persuasion from '../pages/Persuasion.vue'


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
    path: '/persuasion',
    name: 'Persuasion',
    component: Persuasion
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
