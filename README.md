 ###     PIPELINED-PROCESSORS
 #### 1. General Introduction 

 In a pipelined processor, overall performance is highly dependent on how effectively pipeline hazards are handled, particularly data hazards and control hazards caused by branch instructions. Without appropriate handling mechanisms, the pipeline must insert stall cycles or flush instructions, which significantly degrades performance.

To study and evaluate different hazard-handling techniques, this project implements and simulates six pipeline models with varying levels of complexity. These models include pipelines with and without data forwarding, as well as multiple branch prediction strategies ranging from simple static approaches to advanced dynamic predictors. The goal is to analyze how each technique affects pipeline behavior, instruction throughput, and overall execution efficiency.

#### 2. Pipeline Model Descriptions
- ##### 2.1. Non-forwarding Pipeline

The non-forwarding pipeline represents a basic pipelined processor design in which data forwarding is not implemented. When a data hazard occurs—specifically, when an instruction depends on the result of a previous instruction that has not yet completed the write-back stage—the pipeline must stall until the required data becomes available in the register file.

This model serves as a baseline for comparison, illustrating the performance impact of pipeline stalls caused by unresolved data dependencies.

- [Datapath]()
![](./ảnh/ảnh1.jpg)
- [Result]()
<p align="center">
  <img src="./ảnh/ảnh7.png" width="500">
</p>


- ##### 2.2. Forwarding Pipeline with Not Taken Branch Prediction

This pipeline model incorporates data forwarding to mitigate data hazards by allowing intermediate results to be passed directly from later pipeline stages to earlier ones, without waiting for register write-back.

For control hazards, the pipeline employs a static branch prediction strategy that always predicts branches as not taken. Under this approach, the pipeline continues to fetch sequential instructions following a branch instruction until the actual branch outcome is resolved.

If the branch is indeed not taken, pipeline execution proceeds without interruption. However, if the branch is actually taken, the incorrectly fetched instructions are flushed, and execution is redirected to the branch target address.

- [Datapath]()
![](./ảnh/ảnh2.jpg)
- [Result]()
<p align="center">
  <img src="./ảnh/ảnh8.png" width="500">
</p>


- ##### 2.3. Forwarding Pipeline with Always Taken Branch Prediction

Similar to the previous model, this pipeline also uses data forwarding to handle data dependencies between consecutive instructions efficiently.

The branch prediction strategy in this model always predicts branches as taken. When a branch instruction is encountered, the pipeline assumes the branch will be taken and begins fetching instructions from the branch target address.

If the prediction matches the actual branch outcome, pipeline execution continues normally. In the case of a misprediction, the incorrectly fetched instructions are flushed, and the pipeline resumes execution along the correct control path.

- [Datapath]()
![](./ảnh/ảnh3.jpg)
- [Result]()
<p align="center">
  <img src="./ảnh/ảnh9.png" width="500">
</p>

- ##### 2.4. Two-Bit Dynamic Branch Prediction

This model uses a two-bit dynamic branch predictor, where each branch is associated with a 2-bit saturating counter representing the recent behavior of that branch. The counter transitions between strongly taken, weakly taken, weakly not taken, and strongly not taken states based on actual branch outcomes.

By requiring two consecutive mispredictions to change the prediction direction, this approach provides stability against occasional anomalies and allows the predictor to adapt dynamically to program behavior over time.

- [Datapath]()
![](./ảnh/ảnh4.jpg)
- [Result]()
<p align="center">
  <img src="./ảnh/ảnh10.png" width="500">
</p>

- ##### 2.5. G-share Branch Prediction

G-share is a dynamic branch prediction technique based on global branch history. The model uses a Global History Register (GHR) to store the outcomes of the most recent branch instructions executed across the program.

When a branch instruction is encountered, the branch address is XORed with the GHR to form an index into the Pattern History Table. Each table entry contains a prediction counter that determines whether the branch is predicted as taken or not taken.

The XOR-based indexing mechanism helps reduce aliasing in the prediction table and enables the predictor to capture correlations among different branches in the execution flow.
- [Datapath]()
![](./ảnh/ảnh5.jpg)
- [Result]()
<p align="center">
  <img src="./ảnh/ảnh10.png" width="500">
</p>


- ##### 2.6. Tagged Geometric Predictor

The Tagged Geometric Predictor is an advanced branch prediction model designed to leverage multiple branch history lengths simultaneously. Instead of relying on a single global history length, the predictor maintains several prediction tables, each indexed using a different history length selected according to a geometric progression.

Each prediction table entry includes a tag derived from the branch address and history information. During prediction, the predictor searches the tables starting from the longest history. If a matching tag is found, the corresponding prediction is used; otherwise, the predictor falls back to tables with shorter histories.

This hierarchical lookup strategy allows the predictor to combine long-term and short-term branch behavior, improving prediction accuracy for complex control-flow patterns.
- [Datapath]()
![](./ảnh/ảnh6.jpg)
- [Result]()
<p align="center">
  <img src="./ảnh/ảnh11.png" width="500">
</p>

#### 3. Description

First, small diagrams are designed for individual functional blocks such as the ALU, LSU, and Register File to describe the logic signals and arithmetic operations within each block. For example, the following diagram illustrates the addition and subtraction operations in the ALU.

- [Diagram]()
<p align="center">
  <img src="./ảnh/ảnh12.png" width="300">
</p>

- [Diagram]()
![](./ảnh/ảnh13.png)

Second, a testbench is implemented to test and verify the functional correctness of the ALU block.
- [Test ALU]()
<p align="center">
  <img src="./ảnh/ảnh14.png" width="300">
</p>

- [Waveform ]()
![](./ảnh/ảnh15.png)

##### Program the DE2 board

![](./ảnh/ảnh16.png)

