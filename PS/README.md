請將「TOP」和「Other Modules」中的所有檔案下載至 Vivado，並依照下方圖片（Vivado_Block_Design.png）建立 Block Design。
將 BRAM Controller 的 Base Address 設定為 0x4000_0000，Address Range 設定為 32K（0x10000）。
在 AXI Interconnect 中啟用 FIFO 功能。
完成 Block Design 後，匯出 .tcl、.hwh、.bit 三個檔案，並在Jupyter Notebook執行「Preprocess」資料夾中的程式碼。
請確保這三個檔案的檔名一致。

![Alt Text](Vivado_Block_Design.png)

