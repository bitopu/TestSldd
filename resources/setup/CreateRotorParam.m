%% Script thao tác với SLDD: Tạo, Cập nhật và Đóng
slddName = 'Rotor.sldd';

% 1. Tạo mới hoặc Mở SLDD
% Nếu file đã tồn tại, nó sẽ mở ra. Nếu chưa, nó sẽ tạo mới.
ddObj = Simulink.data.dictionary.create(slddName);

% 2. Truy cập vào phần 'Design Data' (nơi chứa các tham số mô phỏng)
dSection = getSection(ddObj, 'Design Data');

% 3. Định nghĩa và Cập nhật các Params
% Danh sách các tham số cần thêm/cập nhật
params = struct(...
    'RT_RotorRadius_P', 7.82, ...
    'RT_BladeFlapInertia_P', 2500, ...
    'RT_Cl_alpha_P', 5.7, ...
    'RT_Chord_P', 0.53);

fNames = fieldnames(params);

for i = 1:length(fNames)
    pName = fNames{i};
    pVal = params.(pName);
    
    % Kiểm tra xem tham số đã tồn tại trong SLDD chưa
    entryObj = getEntry(dSection, pName);
    
    if isempty(entryObj)
        % Nếu chưa có thì tạo mới (dưới dạng đối tượng Simulink.Parameter)
        newParam = Simulink.Parameter;
        newParam.Value = pVal;
        newParam.DataType = 'single'; % Hoặc 'double' tùy ông
        addEntry(dSection, pName, newParam);
        fprintf('Đã thêm mới: %s\n', pName);
    else
        % Nếu đã có thì cập nhật giá trị
        tempParam = getValue(entryObj);
        tempParam.Value = pVal;
        setValue(entryObj, tempParam);
        fprintf('Đã cập nhật: %s\n', pName);
    end
end

% 4. Lưu thay đổi và Đóng
saveChanges(ddObj);
discardChanges(ddObj); % Giải phóng bộ nhớ (không làm mất dữ liệu đã save)
close(ddObj);

fprintf('--- Hoàn tất thao tác với %s ---\n', slddName);