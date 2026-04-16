%% Script cập nhật SLDD (Xử lý file đã tồn tại)
slddPath = 'D:\Viettel\Simulation\TestGit\resources\params\Rotor.sldd';

% 1. Dọn dẹp bộ nhớ trước khi chạy
Simulink.data.dictionary.closeAll();

% 2. Mở hoặc Tạo mới (create tự động mở nếu file đã tồn tại)
if exist(slddPath, 'file')
    ddObj = Simulink.data.dictionary.open(slddPath);
    fprintf('Đang mở file hiện có: %s\n', slddPath);
else
    % Tự tạo thư mục nếu chưa có
    [parentDir, ~, ~] = fileparts(slddPath);
    if ~exist(parentDir, 'dir'), mkdir(parentDir); end
    
    ddObj = Simulink.data.dictionary.create(slddPath);
    fprintf('Đã tạo file mới tại: %s\n', slddPath);
end

% 3. Truy cập Design Data
dSection = getSection(ddObj, 'Design Data');

% 4. Danh sách tham số cập nhật
params = struct(...
    'RT_RotorRadius_P', 7.82, ...
    'RT_BladeFlapInertia_P', 2500, ...
    'RT_Cl_alpha_P', 5.7, ...
    'RT_Chord_P', 0.53, ...
    'RT_InertiaLead_P',3000);
    'RT_FlapInertia_P', 2000);

fNames = fieldnames(params);

for i = 1:length(fNames)
    pName = fNames{i};
    pVal = params.(pName);
    
    % Kiểm tra sự tồn tại của Entry trước khi lấy để tránh lỗi "not present"
    entryObj = find(dSection, 'Name', pName);
    
    if isempty(entryObj)
        % THÊM MỚI nếu chưa có
        newParam = Simulink.Parameter;
        newParam.Value = pVal;
        newParam.DataType = 'single'; 
        addEntry(dSection, pName, newParam);
        fprintf('  [NEW] %s\n', pName);
    else
        % CẬP NHẬT nếu đã có
        targetEntry = getEntry(dSection, pName);
        tempVal = getValue(targetEntry);
        
        if isa(tempVal, 'Simulink.Parameter')
            tempVal.Value = pVal;
        else
            tempVal = pVal;
        end
        
        setValue(targetEntry, tempVal);
        fprintf('  [UPDATED] %s\n', pName);
    end
end

% 5. Lưu và Đóng an toàn
saveChanges(ddObj);
Simulink.data.dictionary.closeAll();

fprintf('--- Hoàn tất cập nhật SLDD ---\n');