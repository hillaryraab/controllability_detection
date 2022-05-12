function  [fx] = e_aSS0_aSAS0_aOM1_wOM2(x,P,u,in)
%%%% Evolution function of the TS model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameter transformation / should always be performed.

% raw parameters correspond to the x=x transformation.
for pp = 1:length(P)  
    P(pp) = in.param_transform{pp}(P(pp));   
end

% report x's
fx = x;
omegaalpha = P(1);
omegaalpha_neg = P(1);
omegaexp = P(2);
omegabias = P(3);

%%%%% case where we should update transition matrices and controllability
if u(1)==1
    
    % previous state
    prv_s = u(2);
    prv_c = u(4);
    cur_s = u(11);
        
    % compute prediction errors generated by each transition matrix
    try
        SS_pe_toO = (1-x(in.hs.map.SS{1}(prv_s,cur_s)));
    end
       
   SAS_pe_toO = (1-x(in.hs.map.SAS{1}(prv_c,cur_s)));        

    % compute controllability prediction error and update
    obs_diff_omega = SS_pe_toO-SAS_pe_toO;
    % update expected diff
    if obs_diff_omega-x(19)<0
        fx(in.hs.map.omega) = x(in.hs.map.omega)+omegaalpha_neg*(obs_diff_omega-x(19));
    else
        fx(in.hs.map.omega) = x(in.hs.map.omega)+omegaalpha*(obs_diff_omega-x(19));     
    end
    % update sigtransformed omega
    fx(in.hs.map.sigomega) = VBA_sigmoid(fx(in.hs.map.omega), 'slope', omegaexp, 'center', omegabias);
    
    
%%%%% case predictive trial

elseif u(1)==2  && ~isnan(u(22))% case predictive trial
    
    prv_s = u(19);
    prv_c = u(20); % action tested
    cur_s = u(21); % choice performed (hypothetical cur_s)
    prv_rew = u(22); % reward or not

    % compute prediction errors generated by each transition matrix
     SS_pe_toO = abs(prv_rew-x(in.hs.map.SS{1}(prv_s,cur_s)));
     SAS_pe_toO = abs(prv_rew-x(in.hs.map.SAS{1}(prv_c,cur_s)));        
    
  % compute controllability prediction error and update
    obs_diff_omega = SS_pe_toO-SAS_pe_toO;
    % update expected diff
    if obs_diff_omega-x(19)<0
        fx(in.hs.map.omega) = x(in.hs.map.omega)+omegaalpha_neg*(obs_diff_omega-x(19));
    else
        fx(in.hs.map.omega) = x(in.hs.map.omega)+omegaalpha*(obs_diff_omega-x(19));     
    end
    % update sigtransformed omega
    fx(in.hs.map.sigomega) = VBA_sigmoid(fx(in.hs.map.omega), 'slope', omegaexp, 'center', omegabias);
    
end
% 
% %% helper functions
% function ux = reset_all(in,x, P,u)
%     ux(in.hs.map.SS(:),1) = in.hs.val.SS(:);
%     for i = 1:3
%         ux(in.hs.map.SAS{i}(:),1) = in.hs.val.SAS{i}(:);
%     end
%     ux(in.hs.map.omega,1) =x(in.hs.map.omega);
% end

end