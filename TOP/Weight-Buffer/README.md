**#Weight-Buffer**<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;由於我們的convolution在每一輪的計算皆會用到weight參數，因此我們設計了Weight-Buffer，在每次要開始做計算前等9個慢的clock cycle，把9個weight從BRAM拿出來並存進register之後，才開始做計算。
