clear all
import org.opensim.modeling.*
path='C:\Program Files\OpenSim 4.1\Geometry';
ModelVisualizer.addDirToGeometrySearchPaths(path);

%% File address %%
folder = 'C:\MyCloud\GitHub\OpenSimScripting\Matlab\Data\Gait2354_Simbody\';
Scalemodel='subject01_scaledOnly.osim';
CMCSetup='subject01_Setup_CMC.xml';
IKSteup='subject01_Setup_IK.xml';
DynamicMarkerFile='New_subject01_walk1.trc';
ExForceSetup='subject01_walk1_grf.xml';
Markerfile=[folder 'New_subject01_walk1.trc'];
results_folder = [folder 'Out_put\'];
name='subject01';
IK_file=[results_folder name '_ik.mot'];
genericSetupForScale='subject01_Setup_Scale.xml';
NewExForcesetup=[results_folder 'New_subject01_walk1_grf.xml'];

%% Scale ToolBox %%
scale = ScaleTool([folder genericSetupForScale]);
% scale.run();

%% Model initiate %%
model = Model(fullfile([folder, Scalemodel]));
model.initSystem();

%%  Setup the External Force File  %%
ExLoad=ExternalLoads([folder ExForceSetup],true);
ExLoad.setDataFileName([folder 'New_subject01_walk1_grf.mot']);
ExLoad.print(NewExForcesetup)

%% IK %%
%%% Get trc data to determine time range
markerData = MarkerData(Markerfile); 
initial_time = markerData.getStartFrameTime();
final_time = markerData.getLastFrameTime();
%%%
%%% To creat ik tool without any xml file
% ikTool=InverseKinematicsTool();
% ikTool.setName(name);
%%% 
%%% To creat ik tool with xml file and further changes
ikTool=InverseKinematicsTool([folder IKSteup]); % to read xml file for IK
ikTool.setModel(model);
ikTool.setMarkerDataFileName(Markerfile);
ikTool.setStartTime(initial_time);
ikTool.setEndTime(final_time);
ikTool.setOutputMotionFileName(IK_file);
ikTool.print([results_folder name '_IK_Setup.xml']);
% % ikTool.getIKTaskSet() % to change the scale files
% ikTool.run();
%% ID
idTool=	InverseDynamicsTool([folder IDSteup]);
idTool.setStartTime(FTable.data(1,1));
idTool.setEndTime(FTable.data(end,1));
idTool.setCoordinatesFileName(IkFile);
idTool.setExternalLoadsFileName(NewExForcefile);
idTool.setResultsDir(append(results_folder,"ID\"))
idTool.setOutputGenForceFileName(append(filename,"_ID.sto"))
idTool.print(append(results_folder,"ID\",filename,"_ID_Setup.xml"));
idTool.run();
%%  SOP %%
%%% Construct SOP %%%%
motion = Storage(IK_file);
static_optimization = StaticOptimization();
static_optimization.setStartTime(motion.getFirstTime());
static_optimization.setEndTime(motion.getLastTime());
static_optimization.setUseModelForceSet(true);
static_optimization.setUseMusclePhysiology(true);
static_optimization.setActivationExponent(2);
static_optimization.setConvergenceCriterion(0.0001);
static_optimization.setMaxIterations(100)
model.addAnalysis(static_optimization)
%%%Analysis
analysis = AnalyzeTool(model);
analysis.setName(name);
analysis.setModel(model);
analysis.setInitialTime(motion.getFirstTime());
analysis.setFinalTime(motion.getLastTime());
analysis.setLowpassCutoffFrequency(6);
analysis.setCoordinatesFileName(IK_file);
analysis.setExternalLoadsFileName(NewExForcesetup);
analysis.setLoadModelAndInput(true);
analysis.setResultsDir([results_folder 'SOP']);
analysis.run();
% static optim
%%  CMC  %%
% look at AbstractTool () to find more subclass for time range 
cmc = CMCTool([folder CMCSetup]);
cmc.setDesiredKinematicsFileName([results_folder name '_ik.mot']);
cmc.setExternalLoadsFileName([results_folder 'New_subject01_walk1_grf.xml']);
cmc.setStartTime(0.9);
cmc.setFinalTime(0.95);
cmc.setResultsDir([folder 'CMC']);
cmc.run();
%% Momentum Arm Calculation %%
Musclename='bflh_l';
coordinatename='knee_angle_l';
force = model.getForceSet().get(Musclename);
muscle = Millard2012EquilibriumMuscle.safeDownCast(force);
coord = model.updCoordinateSet().get(coordinatename);
coord.setValue(state,0.1);
muscle.computeMomentArm(state, coord);
