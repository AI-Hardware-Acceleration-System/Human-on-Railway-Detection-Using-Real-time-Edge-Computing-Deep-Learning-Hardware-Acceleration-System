#作品簡介<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;火車站月臺有人落軌的新聞時有耳聞，為了解決現況，我們提出了一套能夠即時識別人體落軌的監測及通報系統。這套系統包含了能夠準確辨識人體落軌的AI模型開發與訓練，以及能夠即時進行推理的AI運算加速器設計。同時我們完成軟硬體整合，並以FPGA來展示我們的設計原形。我們也重複使用硬體和運用獨特的圖片預處理技術來進行加速器的設計。同時，我們增加了整體吞吐量(throughput)以減少閒置時間。<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;實際運作流程會先以FPGA的Processing System(PS)端連接鏡頭進行實況拍攝及圖片預處理，再將軟體端訓練完成的CNN模型參數存入FPGA板的Programmable Logic(PL)端的BRAM，以便進行運算加速及結果判斷，最終輸出的判斷結果若為「有人」，則會進行即時的站內警報。藉由低廉的成本以及即時且精準的判斷結果，此系統可以很好的避免落軌事件所產生的傷亡。<br/>
    成品概念圖如下:<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Product_concept_2.jpg)<br/>

“CNN_Software”含訓練模型參數的程式碼；“PS”含預處理的程式碼；“TOP” 包含了所有計算加速會用到的程式碼；“Testbench”含電路的驗證檔。<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/architecture_1.png)<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/architecture_2.png)<br/>

