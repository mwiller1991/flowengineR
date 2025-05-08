# Workflow Diagram

Hier ist ein Diagramm, das den Workflow visualisiert:

```mermaid
graph TD
    %% Meta Level
    Input(User Input: Control Object):::object ==> B[fairness_workflow-function]
    Input ==> C[fairness_workflow_variants-function]

    %% fairness_workflow_variants internal structure
    subgraph fairness_workflow_variants
        direction LR
        C --> Input1[original control]:::object
        Input1 -->|modifying| Input2[bestestimate_control]:::object
        Input1 -->|modifying| Input3[unawareness_control]:::object
        Input1 --> Loop1[Loop-function]:::helper_style
        Input2 --> Loop1
        Input3 --> Loop1
        Loop1 -->|final results per loop| I2(Final Results: Models, Predictions, Metrics per run):::object
    end

    Loop1 -->|calling per calibration variant| B
    B -->|returning results| Loop1

    %% fairness_workflow internal structure
    subgraph fairness_workflow
        direction TB
        B -->|calls| Dec1{User split delivered?}:::decider
        B -->|calls| Re1[Standardized Inputs: workflow_results, split_output, alias, params]:::input_style
        B -->|calls| R1[Standardized Inputs: reportelement_results, alias, params]:::input_style
            %% Splitter
        subgraph Splitter
            direction TB
                Dec1 -->Ans2((No)):::no
                Dec1 -->Ans1((Yes)):::yes
            Ans2 -->|full dataset| Sp1[Standardized Inputs: data, protected_attributes, target_var, params]:::input_style
            Ans1 -->|seperated dataset, dummy engine = userdefined| Sp1
            Sp1 --> E1[Split Engine]:::engine
            C1[function: controller_split]:::controller_style -->|rest| Sp1
            E1 --> OF1[function: initialize_output_split]:::output_style
            OF1 --> Sp2[Standardized Outputs with defaults: split_type, splits, seed, params = NULL, specific_output = NULL]:::input_style
        end
        Sp2 -->|splits| IR1[split_output]:::object
        IR1 -->|splits| I
        WR[workflow_results]:::object -->|results for each split| I
        WR --> AGG[aggregate_results]:::helper_style
        AGG --> AR[aggregated_results]:::object
        AR --> I

        subgraph reportelement
            direction TB
            C7[function: controller_reportelement]:::controller_style -->|params| Re1
            Re1 --> E7[Reportelement Engine]:::engine
            E7 --> OF7[function: initialize_output_reportelement]:::output_style
            OF7 --> Re2[Standardized Outputs with defaults: report_object, report_type, input_data, params = NULL, specific_output = NULL]:::input_style
        end

        WR -->|workflow_results| Re1
        IR1 -->|split_output| Re1
        Re2 -->|standardized output| ReEl1[reportelement_results]:::object

        subgraph report
            direction TB
            C8[function: controller_report]:::controller_style -->|params| R1
            R1 --> E8[Report Engine]:::engine
            E8 --> OF8[function: initialize_output_report]:::output_style
            OF8 --> R2[Standardized Outputs with defaults: report_title, report_type, compatible_formats, sections, params = NULL, specific_output = NULL]:::input_style
        end

        ReEl1 -->|reportelement_results| R1
        R2 -->|standardized output| RRes1[report_results]:::object

        ReEl1 -->|standardized output| I(Final Results: Models, Predictions, Metrics):::object
        RRes1 -->|standardized output| I(Final Results: Models, Predictions, Metrics):::object
    end

    %% Workflow inside run_workflow_single
    subgraph Workflow in run_workflow_single
        direction TB
        IR1 -->|splited dataset in loops| D[run_workflow_single]
        D[run_workflow_single] -->|raw data| Dec2{Fairness-Pre-Precessing Active?}:::decider
            Dec2 -->Ans3((Yes)):::yes
            Dec2 -->Ans4((No)):::no

        %% Embedded In-Processing Engine
        subgraph Fairness In-Processing Engines
        direction TB
            Ans3 -->|data| FPr1[Standardized Inputs: data, protected_attributes, target_var, params]:::input_style
            FPr1 --> E2[Fairness-Pre-Precessing Engine]:::engine
            C2[function: controller_fairness_pre]:::controller_style -->|rest| FPr1
            E2 --> OF2[function: initialize_output_fairness_pre]:::output_style
            OF2 --> FPr2[Standardized Outputs with defaults: preprocessed_data, method, params = NULL, specific_output = NULL]:::input_style
        end
        
        %% Normalizing data
        subgraph Normalizing data
        direction TB
            FPr2 -->|Preprocessed data| Hlp1[function: normalize_data]:::helper_style
            Ans4 -->|data| Hlp1
        end

        %% Embedded Training-Processing
        subgraph Training Process
            subgraph Training Engines
            direction TB
                Hlp1 -->|original and normalized data| T1[Standardized Inputs: formula, data, norm_data, params]:::input_style
                T1 --> E3[Training Engine]:::engine
                C3[function: controller_train]:::controller_style -->|rest| T1
                E3 --> OF3[function: initialize_output_train]:::output_style
                OF3 --> T2[Standardized Outputs with defaults: model, model_type, formula, predictions = NULL, hyperparameters = NULL, specific_output = NULL]:::input_style
            end

            T2 -->|model| Dec3{Fairness-In-Precessing Active?}:::decider
            Dec3 -->Ans5((Yes)):::yes

            subgraph In-Processing Engines
            direction TB
                Ans5-->|driver_train and control_for_training| FIn1[Standardized Inputs: driver_train, data, protected_attribute_names, params, control_for_training]:::input_style
                Hlp1 -->|original and normalized data| FIn1
                FIn1 --> E4[Fairness-In-Precessing Engine]:::engine
                C4[function: controller_fairness_in]:::controller_style -->|rest| FIn1
                E4 --> OF4[function: initialize_output_fairness_in]:::output_style
                OF4 --> FIn2[Standardized Outputs with defaults: adjusted_model, model_type, predictions = NULL, params = NULL, specific_output = NULL]:::input_style
            end

            Dec3 -->Ans6((No)):::no
            FIn2 --> |adjusted model|RP(Predictions):::object
            Ans6 -->|model| RP

            RP --> |predictions|T2
            RP --> |predictions|FIn2
        end

        %% Integrated Fairness Post-Processing Subgraph
        subgraph Fairness Post-Processing Engines
            direction TB
            Ans7 -->|fairness_post_data including Raw Predictions| FP1[Standardized Inputs: fairness_post_data, params, protected_name]:::input_style
            FP1 --> E5[Fairness-Post-Precessing Engine]:::engine
            C5[function: controller_fairness_post]:::controller_style -->|rest| FP1
            E5 --> OF5[function: initialize_output_fairness_post]:::output_style
            OF5 --> FP2[Standardized Outputs with defaults: adjusted_predictions, method, input_data, protected_attributes, params = NULL, specific_output = NULL]:::input_style
        end

        %% Decision after Predictions
        RP --> Dec4{Fairness-Post-Precessing Active?}:::decider
            Dec4 -->Ans7((Yes)):::yes
            Dec4 -->Ans8((No)):::no
        Ans8 -->|raw redictions| Dec5{Evaluation in use?}:::decider
            FP2 -->|adjusted predictions| Dec5
            Dec5 -->Ans9((Yes)):::yes
            Dec5 -->Ans10((No)):::no


        %% Integrated Eval Subgraph
        subgraph Evaluations Engines
            Ans9 -->|eval_data including raw or adjusted predictions| Ev1[Standardized Inputs: eval_data, params, protected_name]:::input_style
            Ev1 --> E6[Evaluation Engine]:::engine
            C6[function: controller_evaluation]:::controller_style -->|rest| Ev1
            E6 --> OF6[function: initialize_output_eval]:::output_style
            OF6 --> Ev2[Standardized Outputs with defaults: metrics, eval_type, input_data, protected_attributes = NULL, params  = NULL, specific_output = NULL]:::input_style
        end
        
        %% Intermediate Results generation
        FPr2 -->|standardized output| IR(Intermediate Results):::object
        T2 --> |standardized output| IR
        FIn2 --> |standardized output| IR
        FP2 -->|standardized output| IR
        Ev2 -->|standardized output| IR
        

    end

    %% Connectiong control-objekt (user-input) to controller_functions
    Input -->|input| C1
    Input -->|input| C2
    Input -->|input| C3
    Input -->|input| C4
    Input -->|input| C5
    Input -->|input| C6
    Input -->|input| C7

    %% Feedback loop to the fairness_workflow
    IR -->|Results for each split| WR[workflow_results]:::object



%% Legend
subgraph Legend
    direction TB
    Obj[Object: Data or Results]:::object
    Dec{Decision: Condition to Proceed}:::decider
    Eng[Engine: Processing Component]:::engine
    Ctr[Controller: Manages Inputs]:::controller_style
    IO1[Input: Standardized Input Formats]:::input_style
    IO2[Output: Standardized Output Formats]:::output_style
    Hlp[Helper: Supporting Function]:::helper_style
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

%% Styling for helper-function
classDef helper_style fill:#D5B3E6,stroke:#000,stroke-width:2px,color:#000;