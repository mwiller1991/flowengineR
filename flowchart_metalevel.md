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
        E2 -->|data including Preprocessed data| T1
            Dec2 -->Ans4((No)):::no

        %% Embedded In-Processing
        subgraph Training Process
            subgraph Training Engines
            direction TB
                Ans4 -->|data| T1[Standardized Inputs: formula, data, params]:::input_style
                T1 --> E3[Training Engine]:::engine
                C3[function: controller_train]:::controller_style -->|rest| T1
                E3 --> OF3[function: initialize_output_train]:::output_style
                OF3 --> T2[Standardized Outputs: model, model_type, training_time, specific_output]:::input_style
            end
            T2 -->|model| Dec3{Fairness-In-Precessing Active?}:::decider
                Dec3 -->Ans5((Yes)):::yes
            Ans5-->|model| E4[Fairness-In-Precessing Engine]:::engine
                Dec3 -->Ans6((No)):::no
            E4 --> |adjusted model|RP(Predictions):::object
            Ans6 -->|model| RP
            RP --> |predictions|T2
        end

        %% Integrated Fairness Post-Processing Subgraph
        subgraph Fairness Post-Processing Engines
            direction TB
            Ans7 -->|fairness_post_data including Raw Predictions| FP1[Standardized Inputs: fairness_post_data, params, protected_name]:::input_style
            FP1 --> E5[Fairness-Post-Precessing Engine]:::engine
            C5[function: controller_fairness_post]:::controller_style -->|rest| FP1
            E5 --> OF5[function: initialize_output_fairness_post]:::output_style
            OF5 --> FP3[Standardized Outputs: adjusted_predictions, method, input_data, specific_output]:::input_style
        end

        %% Decision after Predictions
        RP --> Dec4{Fairness-Post-Precessing Active?}:::decider
            Dec4 -->Ans7((Yes)):::yes
            Dec4 -->Ans8((No)):::no
        Ans8 -->|raw redictions| Dec5{Evaluation in use?}:::decider
            FP3 -->|adjusted predictions| Dec5
            Dec5 -->Ans9((Yes)):::yes
            Dec5 -->Ans10((No)):::no


        %% Integrated Eval Subgraph
        subgraph Evaluations Engines
            Ans9 -->|eval_data including raw or adjusted predictions| Ev1[Standardized Inputs: eval_data, params, protected_name]:::input_style
            Ev1 --> E6[Evaluation Engine]:::engine
            C6[function: controller_evaluation]:::controller_style -->|rest| Ev1
            E6 --> OF6[function: initialize_output_eval]:::output_style
            OF6 --> Ev3[Standardized Outputs: metrics, eval_type, input_data, protected_attributes, params, specific_output]:::input_style
        end
        
        %% Intermediate Results generation
        T2 --> |standardized output| IR(Intermediate Results):::object
        FP3 -->|standardized output| IR
        Ev3 -->|standardized output| IR

    end

    %% Connectiong control-objekt (user-input) to controller_functions
    A -->|input| C3
    A -->|input| C5
    A -->|input| C6

    %% Feedback loop to the Splitter
    IR -->|Intermediate Results| F1

    %% Pass final results back to run_workflow
    F1 -->|Aggregated Results| B

    %% Outputs
    B ==> I(Final Results: Models, Predictions, Metrics):::object
    C ==>|Multiple variants results| I

    %% Variants
    C --> |Configuration Variants|B
    B --> |Variants Results|C

    %% Legend
    subgraph Legend
        direction TB
        Obj[Object: Data or Results]:::object
        Dec{Decision: Condition to Proceed}:::decider
        Eng[Engine: Processing Component]:::engine
        Ctr[Controller: Manages Inputs]:::controller_style
        IO1[Inputs/Outputs: Standardized Input/Output Formats]:::input_style
        IO2[Output-function: Output-function Formats]:::output_style
        Y((Yes: Positive Decision)):::yes
        N((No: Negative Decision)):::no
    end

    %% Styling for engines
    classDef engine fill:#ADD8E6,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for controller
    classDef controller_style fill:#FFE4B5,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for output function
    classDef output_style fill:#32CD32,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for inputs/outputs
    classDef input_style fill:#FFB6C1,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for deciders
    classDef decider fill:#D3D3D3,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for Yes
    classDef yes fill:#90EE90,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for No
    classDef no fill:#FFCCCB,stroke:#000,stroke-width:2px,color:#000;

    %% Styling for objects
    classDef object fill:#D8BFD8,stroke:#000,stroke-width:2px,color:#000;