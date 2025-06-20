**#作品簡介**<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;火車站月臺有人落軌的新聞時有耳聞，為了解決現況，我們提出了一套能夠即時識別人體落軌的監測及通報系統。這套系統包含了能夠準確辨識人體落軌的AI模型開發與訓練，以及能夠即時進行推理的AI運算加速器設計。同時我們完成軟硬體整合，並以FPGA來展示我們的設計原形。我們也重複使用硬體和運用獨特的圖片預處理技術來進行加速器的設計。同時，我們增加了整體吞吐量(throughput)以減少閒置時間。<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;實際運作流程會先以FPGA的Processing System(PS)端連接鏡頭進行實況拍攝及圖片預處理，再將軟體端訓練完成的CNN模型參數存入FPGA板的Programmable Logic(PL)端的BRAM，以便進行運算加速及結果判斷，最終輸出的判斷結果若為「有人」，則會進行即時的站內警報。藉由低廉的成本以及即時且精準的判斷結果，此系統可以很好的避免落軌事件所產生的傷亡。<br/><br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;成品概念圖如下:<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Product_concept_2.jpg)<br/>

<br/>

**#系統架構**<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;本系統自行設計的架構如下圖，包含了軟體端及硬體端的設計及整合。其中硬體端又涵蓋了PS端與PL端的設計。<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;為了能在硬體資源受限的情況下達到理想的偵測準確率，我們選擇了卷積神經網路（CNN），因其結構簡單又具備良好圖像辨識能力。軟體端會以PyTorch訓練CNN模型的參數及使用YOLOv5得到月臺交界線的兩點座標以進行月臺資料清除的準備作業。接著將CNN模型參數燒入FPGA的PL端BRAM中，並將月臺交界線兩點座標匯入FPGA的PS端。硬體端則藉由PS端來去除月台區域、與相機對接溝通及圖片的預處理，並將子圖片經由AXI送往PL端。PL端則以Verilog實現CNN模型運算的硬體加速電路且會將預處理過的子圖片以及訓練好的模型參數進行卷積、池化、全連接等操作並在最後輸出判斷結果。<br/>
>![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/architecture_1.png)<br/><br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;系統具體判斷流程如下所示:<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/architecture_2.png)<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;一開始會藉由攝影機進行即時的影片拍攝，接著會將每幀圖片中的月臺資料清除再進行圖片的切割並對每一個子圖像進行判斷，若任何一張子圖像判斷結果為有落軌事件，則整個系統即會觸發警報。<br/>

<br/>

**#系統程式碼介紹**<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在本專案中:<br/>
>- “CNN_Software”含人像辨識CNN模型之訓練模型參數的程式碼。<br/>
>- “PS”含圖片預處理及PS端相關的程式碼。<br/>
>- “TOP” 包含了所有PL端計算加速會用到的程式碼。<br/>
>- “Testbench”含電路的驗證檔。<br/><br/>
>詳情請見各資料夾內的README.md
