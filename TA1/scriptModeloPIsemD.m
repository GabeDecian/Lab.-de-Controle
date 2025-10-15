% T1 - Simulacao de Sistemas de Controle 
% Ultima modificacao: 20/09/2025
% Descricao: Analise da resposta ao degrau de um controlador PI sem derivativo

% Valores especificados no enunciado
Kp_values = [0.5, 1, 2, 10];     % Ganhos proporcionais
Ti_values = [Inf, 10, 1, 0.1];   % Tempos integrais (s)

% Parametros da simulacao
t_final = 20;        % Duracao da simulacao (s)
step_size = 0.001;   % Passo fixo do solver

% Nome do modelo Simulink
modelName = 'modeloPIsemD';
load_system(modelName);

% Configuracao de cores e estilos para os graficos
colors = [0 0.4470 0.7410;       % Azul (Kp=0.5)
          0.8500 0.3250 0.0980;   % Laranja (Kp=1)
          0.2 0.7 0.2;            % Verde (Kp=2)  
          0.6 0.1 0.6];           % Roxo (Kp=10)
styles = {'-', '--', ':', '-.'};  % Estilos de linha distintos
linewidths = [1.5, 2.0, 1.5, 2.0]; % Espessuras variadas

% Configura parametros do modelo
set_param(modelName, ...
    'StopTime', num2str(t_final), ...
    'Solver', 'ode45', ...
    'FixedStep', num2str(step_size), ...
    'MaxStep', num2str(step_size), ...
    'SaveOutput', 'on', ...
    'SaveTime', 'on', ...
    'SaveFormat', 'StructureWithTime', ...
    'SignalLogging', 'on', ...
    'SignalLoggingName', 'logsout');

%% Gerar 4 figuras conforme enunciado: uma para cada Ti
for j = 1:length(Ti_values)
    Ti_val = Ti_values(j);
    
    % Tratamento do Ti infinito conforme enunciado
    if isinf(Ti_val)
        Ti = 1/eps;              % Ti infinito
        Gain1_value = eps;       % 1/Ti = 1/(1/eps) = eps
        Ti_str = 'inf';
        Ti_display = '\infty';
    else
        Ti = Ti_val;
        Gain1_value = 1/Ti;      % 1/Ti normal
        Ti_str = strrep(num2str(Ti_val), '.', '_');
        Ti_display = num2str(Ti_val);
    end

    % Debug: mostrar valores configurados
    fprintf('Figura %d: Ti = %s, Gain1 = %.6f\n', j, Ti_display, Gain1_value);
    
    % Criar nova figura
    figure('Position', [100 + j*50, 100 + j*50, 800, 600], 'Color', 'white');
    hold on;

    for i = 1:length(Kp_values)
        Kp = Kp_values(i);

        % Configurar os ganhos no modelo Simulink
        set_param([modelName '/Gain'], 'Gain', num2str(Kp));        % Kp
        set_param([modelName '/Gain1'], 'Gain', num2str(Gain1_value)); % 1/Ti

        % Executar simulacao
        sim(modelName);

        % Extrair dados da simulacao
        t = saida.time;
        y = saida.signals.values;

        % Plotar curva
        plot(t, y, 'Color', colors(i,:), 'LineStyle', styles{i}, ...
             'LineWidth', linewidths(i), 'DisplayName', ['K_p = ' num2str(Kp)]);
    end

    % Formatacao do grafico
    if isinf(Ti_val)
        title_str = 'Resposta ao Degrau Unitario - T_i = \infty (Controlador P)';
        filename = 'grafico_Ti_inf';
    else
        title_str = ['Resposta ao Degrau Unitario - T_i = ' num2str(Ti_val) ' s'];
        filename = ['grafico_Ti_' Ti_str];
    end
    
    % Configurar fundo branco e textos pretos
    set(gcf, 'Color', 'white');  % Fundo da figura branco
    set(gca, 'Color', 'white');  % Fundo dos eixos branco
    
    title(title_str, 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'black');
    xlabel('Tempo (s)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'black');
    ylabel('Saida y(t)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'black');
    
    % Configurar eixos e grid com cores pretas
    set(gca, 'XColor', 'black', 'YColor', 'black', 'FontSize', 11);
    set(gca, 'GridColor', 'black', 'GridAlpha', 0.3);
    
    legend('Location', 'best', 'FontSize', 11, 'TextColor', 'black', ...
           'EdgeColor', 'black', 'Color', 'white');
    grid on;
    xlim([0 t_final]);
    
    % Linha de referencia no setpoint
    yline(1, 'k--', 'LineWidth', 1, 'Alpha', 0.5, 'HandleVisibility', 'off');
    
    hold off;

    % Salvar grafico
    saveas(gcf, [filename '.png']);
    saveas(gcf, [filename '.fig']);
    
    fprintf('Figura %d salva: %s\n', j, filename);
end

%% Gerar 4 figuras adicionais conforme enunciado: uma para cada Kp
for i = 1:length(Kp_values)
    Kp = Kp_values(i);
    Kp_str = strrep(num2str(Kp), '.', '_');
    
    % Debug: mostrar Kp configurado
    fprintf('Figura %d: Kp = %.1f\n', i+4, Kp);
    
    % Criar nova figura
    figure('Position', [200 + i*50, 200 + i*50, 800, 600], 'Color', 'white');
    hold on;

    for j = 1:length(Ti_values)
        Ti_val = Ti_values(j);
        
        % Tratamento do Ti infinito conforme enunciado
        if isinf(Ti_val)
            Ti = 1/eps;              % Ti infinito
            Gain1_value = eps;       % 1/Ti = 1/(1/eps) = eps
            Ti_display = '\infty';
        else
            Ti = Ti_val;
            Gain1_value = 1/Ti;      % 1/Ti normal
            Ti_display = num2str(Ti_val);
        end

        % Configurar os ganhos no modelo Simulink
        set_param([modelName '/Gain'], 'Gain', num2str(Kp));        % Kp
        set_param([modelName '/Gain1'], 'Gain', num2str(Gain1_value)); % 1/Ti

        % Executar simulacao
        sim(modelName);

        % Extrair dados da simulacao
        t = saida.time;
        y = saida.signals.values;

        % Plotar curva
        plot(t, y, 'Color', colors(j,:), 'LineStyle', styles{j}, ...
             'LineWidth', linewidths(j), 'DisplayName', ['T_i = ' Ti_display ' s']);
    end

    % Formatacao do grafico
    title_str = ['Resposta ao Degrau Unitario - K_p = ' num2str(Kp)];
    filename = ['grafico_Kp_' Kp_str];
    
    % Configurar fundo branco e textos pretos
    set(gcf, 'Color', 'white');  % Fundo da figura branco
    set(gca, 'Color', 'white');  % Fundo dos eixos branco
    
    title(title_str, 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'black');
    xlabel('Tempo (s)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'black');
    ylabel('Saida y(t)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'black');
    
    % Configurar eixos e grid com cores pretas
    set(gca, 'XColor', 'black', 'YColor', 'black', 'FontSize', 11);
    set(gca, 'GridColor', 'black', 'GridAlpha', 0.3);
    
    legend('Location', 'best', 'FontSize', 11, 'TextColor', 'black', ...
           'EdgeColor', 'black', 'Color', 'white');
    grid on;
    xlim([0 t_final]);
    
    % Linha de referencia no setpoint
    yline(1, 'k--', 'LineWidth', 1, 'Alpha', 0.5, 'HandleVisibility', 'off');
    
    hold off;

    % Salvar grafico
    saveas(gcf, [filename '.png']);
    saveas(gcf, [filename '.fig']);
    
    fprintf('Figura %d salva: %s\n', i+4, filename);
end

% Fechar o modelo Simulink
close_system(modelName, 0);

fprintf('\n=== SIMULACAO CONCLUIDA ===\n');
fprintf('8 figuras geradas conforme enunciado:\n');
fprintf('Graficos por Ti (4 figuras):\n');
fprintf('- grafico_Ti_inf\n');
fprintf('- grafico_Ti_10\n');
fprintf('- grafico_Ti_1\n');
fprintf('- grafico_Ti_0_1\n');
fprintf('Graficos por Kp (4 figuras):\n');
fprintf('- grafico_Kp_0_5\n');
fprintf('- grafico_Kp_1\n');
fprintf('- grafico_Kp_2\n');
fprintf('- grafico_Kp_10\n');
