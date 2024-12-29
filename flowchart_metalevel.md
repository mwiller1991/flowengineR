# Workflow Diagram

Hier ist ein Diagramm, das den Workflow visualisiert:

```mermaid
graph TD
    %% Meta Level
    A(User Input: Control Object):::object ==> B[run_workflow]
    A ==> C[run_workflow_variants]
    B -->|full dataset| Dec1{User split delivered?}:::decider
    
    %% Splitter Layer
    subgraph Splitter Layer
        direction TB
            Dec1 -->Ans2((No)):::no
            Dec1 -->Ans1((Yes)):::yes
        Ans2 -->|full dataset| F1[Splitter Engines]:::engine
    end

    %% Workflow inside run_workflow_single
    subgraph Workflow in run_workflow_single
        direction TB
        Ans1 -->|splited dataset| D[run_workflow_single]
        F1 -->|splited dataset| D
        D -->|raw data| Dec2{Fairness-Pre-Precessing Active?}:::decider
            Dec2 -->Ans3((Yes)):::yes
        Ans3 --> E2[Fairness-Pre-Precessing Engine]:::engine
        E2 -->|Preprocessed data| E3
            Dec2 -->Ans4((No)):::no
        Ans4 -->|raw Data| E3[Training Engine]:::engine
        
        %% Embedded In-Processing
        subgraph Training Process
            E3 -->|model| Dec3{Fairness-In-Precessing Active?}:::decider
                Dec3 -->Ans5((Yes)):::yes
            Ans5-->|model| E4[Fairness-In-Precessing Engine]:::engine
                Dec3 -->Ans6((No)):::no
            E4 --> |adjusted model|RP(Predictions):::object
            Ans6 -->|model| RP
        end
        
        %% Decision for Predictions
        RP --> Dec4{Fairness-Post-Precessing Active?}:::decider
            Dec4 -->Ans7((Yes)):::yes
        Ans7 -->|Raw Predictions| E5[Fairness-Post-Precessing Engine]:::engine
            Dec4 -->Ans8((No)):::no
        Ans8 -->|Raw Predictions| E6[Evaluation Engine]:::engine
        

        %% Intermediate Results generation
        E5 -->|Adjusted Predictions| IR(Intermediate Results):::object
        E6 -->|Metrics| IR
        Ans8 -->|Raw Predictions| IR
    end

    %% Feedback loop to the Splitter
    IR -->|Intermediate Results| F1

    %% Pass final results back to run_workflow
    F1 -->|Aggregated Results| B

    %% Outputs
    B ==> I(Final Results: Models, Predictions, Metrics):::object
    C ==>|Multiple variants results| I


    %% Variants
    C -->|Configuration Variants| B
    B -->|Variant Results| C

    %% Legend
    subgraph Legend
        direction TB
        L1[Deciders: Gray Diamonds]:::decider
        L2[Engines: Blue Rectangles]:::engine
        L3[Objects: Purple Rectangles]:::object
        L4[Functions of the package: Black Rectangles]
    end

    %% Styling for engines
    classDef engine fill:#ADD8E6,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for deciders
    classDef decider fill:#D3D3D3,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for Yes
    classDef yes fill:#90EE90,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for No
    classDef no fill:#FFCCCB,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for objects
    classDef object fill:#D8BFD8,stroke:#000,stroke-width:2px,color:#000;