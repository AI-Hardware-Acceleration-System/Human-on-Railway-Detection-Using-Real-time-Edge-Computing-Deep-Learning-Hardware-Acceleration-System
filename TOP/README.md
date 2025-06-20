**本系統之大致hierarchy如下圖所示:**</br>
整合尚未完成，軟體端結果與硬體端計算結果有差異，目前仍在驗證中</br>
</br>
>內部各區塊之詳細hierarchy請參見各資料夾</br>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/system_hireachy.jpg)</br>

</br>
除了下載TOP裡所有資料，亦須在 Vivado 呼叫 Block Memory Gnerator 的 IP。<br/>
BRAM_Control會呼叫到 12 個 BRAM_Big 及 32 個 BRAM_small (共44個)，設定如下(以下除了Write/Read Depth其他兩者設定皆一致)：<br/>

**Basic:**  
- Interface Type: Native  
- Memory Type: True Dual Port RAM  

**Port Options (for both Port A and Port B):**  
- Write/Read Width: 16  
- Write/Read Depth:  
  - BRAM_Big: 6724  
  - BRAM_Small: 1450  
- Disable:
  - Primitives Output Register  
  - Core Output Register


詳請可參考下圖:</br>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/TOP/BRAM_%20Settings.png)
