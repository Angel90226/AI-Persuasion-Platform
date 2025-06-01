/*
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
self["webpackHotUpdateruby_openai"]("main",{

/***/ "./frontend_app/static/canon.jpg":
/*!***************************************!*\
  !*** ./frontend_app/static/canon.jpg ***!
  \***************************************/
/***/ (() => {

eval("throw new Error(\"Module parse failed: Unexpected character '�' (1:0)\\nYou may need an appropriate loader to handle this file type, currently no loaders are configured to process this file. See https://webpack.js.org/concepts#loaders\\n(Source code omitted for this binary file)\");\n\n//# sourceURL=webpack://ruby-openai/./frontend_app/static/canon.jpg?");

/***/ }),

/***/ "./node_modules/unplugin/dist/webpack/loaders/transform.js?unpluginName=unplugin-vue-components!./node_modules/unplugin/dist/webpack/loaders/transform.js?unpluginName=unplugin-auto-import!./node_modules/vue-loader/dist/index.js??ruleSet[1].rules[6].use[0]!./frontend_app/pages/MainTask.vue?vue&type=script&lang=js":
/*!********************************************************************************************************************************************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/unplugin/dist/webpack/loaders/transform.js?unpluginName=unplugin-vue-components!./node_modules/unplugin/dist/webpack/loaders/transform.js?unpluginName=unplugin-auto-import!./node_modules/vue-loader/dist/index.js??ruleSet[1].rules[6].use[0]!./frontend_app/pages/MainTask.vue?vue&type=script&lang=js ***!
  \********************************************************************************************************************************************************************************************************************************************************************************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"default\": () => (__WEBPACK_DEFAULT_EXPORT__)\n/* harmony export */ });\n/* unplugin-vue-components disabled */\n/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = ({\n  name: 'MainTask',\n  data() {\n    return {\n      showPowerCheck: true,\n      powerScore: null,\n      selectedPrinter: null,\n      showDetailDialog: false,\n      detailPrinter: null,\n      printers: [\n        {\n          id: 'canon',\n          name: 'Canon PIXMA TR7820',\n          brand: 'Canon',\n          image: __webpack_require__(/*! ../static/canon.jpg */ \"./frontend_app/static/canon.jpg\"),\n          price: 129.00,\n          specs: [\n            'All-in-One: Print, Copy, Scan',\n            'Print Speed: 15 ppm (black), 10 ppm (color)',\n            '2.7\" LCD Touchscreen',\n            'Auto-Duplex, Auto Document Feeder',\n            'Wireless & USB',\n            '100-sheet paper capacity',\n            'Color: White'\n          ],\n          fullSpecs: [\n            'Model: PIXMA TR7820',\n            'Dimensions: 15.9 x 14.2 x 8.2 inches',\n            'Weight: 16 lbs',\n            'Max Print Size: 8.5\" x 11\"',\n            'Print Resolution: Up to 4800 x 1200 dpi',\n            'Connectivity: USB, Wireless',\n            'Paper Capacity: 100 sheets (cassette), 100 sheets (rear tray)',\n            'ADF: 35 sheets',\n            'Display: 2.7\" LCD Touchscreen',\n            'Compatible OS: Windows, Mac, Mobile',\n            'Warranty: 1 year'\n          ],\n          features: [\n            'Easy setup and maintenance',\n            'Hybrid ink system for sharp text and vivid photos',\n            'Poster Artist Online for banners and signage',\n            'Energy Star certified'\n          ],\n          reviews: [\n            { user: 'Alice', stars: 5, text: 'Great print quality and easy to use!' },\n            { user: 'Bob', stars: 4, text: 'Setup was quick, but color printing is a bit slow.' }\n          ]\n        },\n        {\n          id: 'hp',\n          name: 'HP OfficeJet Pro 8025e',\n          brand: 'HP',\n          image: '/hp.jpg',\n          price: 69.99,\n          specs: [\n            'All-in-One: Print, Copy, Scan, Fax',\n            'Print Speed: 20 ppm (black), 10 ppm (color)',\n            '2.7\" Color Touchscreen',\n            'Auto-Duplex, Auto Document Feeder',\n            'Wireless, Ethernet, USB',\n            '225-sheet input tray',\n            'Color: Gray'\n          ],\n          fullSpecs: [\n            'Model: OfficeJet Pro 8025e',\n            'Dimensions: 18.1 x 20.1 x 9.2 inches',\n            'Weight: 18 lbs',\n            'Max Print Size: 8.5\" x 14\"',\n            'Print Resolution: Up to 4800 x 1200 dpi',\n            'Connectivity: USB, Wireless, Ethernet',\n            'Paper Capacity: 225 sheets',\n            'ADF: 35 sheets',\n            'Display: 2.7\" Color Touchscreen',\n            'Compatible OS: Windows, Mac, Mobile',\n            'Warranty: 1 year'\n          ],\n          features: [\n            'Smart Tasks shortcuts for productivity',\n            'Self-healing Wi-Fi',\n            'HP+ Smart Printing System',\n            'Energy Star certified'\n          ],\n          reviews: [\n            { user: 'Carol', stars: 5, text: 'Fast printing and lots of features for the price.' },\n            { user: 'David', stars: 4, text: 'Good value, but setup took a bit longer than expected.' }\n          ]\n        }\n      ]\n    }\n  },\n  methods: {\n    closePowerCheck() {\n      this.showPowerCheck = false;\n      // 之後可在這裡處理 powerScore 上傳或其他邏輯\n    },\n    selectPrinter(id) {\n      this.selectedPrinter = id;\n    },\n    confirmSelection() {\n      // 這裡可以處理選擇確認後的流程\n      this.$message.success('Your selection has been confirmed!');\n    },\n    showPrinterDetail(printer) {\n      this.detailPrinter = printer;\n      this.showDetailDialog = true;\n    }\n  }\n});\n\n\n//# sourceURL=webpack://ruby-openai/./frontend_app/pages/MainTask.vue?./node_modules/unplugin/dist/webpack/loaders/transform.js?unpluginName=unplugin-vue-components!./node_modules/unplugin/dist/webpack/loaders/transform.js?unpluginName=unplugin-auto-import!./node_modules/vue-loader/dist/index.js??ruleSet%5B1%5D.rules%5B6%5D.use%5B0%5D");

/***/ })

},
/******/ function(__webpack_require__) { // webpackRuntimeModules
/******/ /* webpack/runtime/getFullHash */
/******/ (() => {
/******/ 	__webpack_require__.h = () => ("835519e5ba86746764f7")
/******/ })();
/******/ 
/******/ }
);