# Code for paper: Inverse Reinforcement Q-Learning Through Expert
# Imitation for Discrete-Time Systems. 
# Programing Language : Julia 
# Purpose : Practice and Research

# Lib
using LinearAlgebra
using Plots
using Kronecker
# Model
A = [0.906488 0.0816012 -0.0005;
0.0741349 0.90121 -0.000708383;
0 0 0.132655];
B=[-0.00150808,-0.0096,0.867345][:,:];
C=[0 0 1;0 0.6 0;-1.26 -0.9788 0.4852];
# Expert parameters for data collection
QT=Matrix(Diagonal([15.0,18.0,14.0]));
RT=[2.0][:,:];
KT=[-0.1688 -0.2009 0.1285];
PT=[231.8377  188.4074    0.0316;
188.4074  248.8900    0.0696;
  0.0316    0.0696   14.0394];
HT = [QT+A'*PT*A A'*PT*B;B'*PT*A RT+B'*PT*B];
# Learner parameters
Q0 = Matrix(Diagonal([0.1,0.5,1.0]));
# Q = Vector{Float64}[];
# Q[1]=Q0;
R=[1.0][:,:];
alpha=1.0;
# Collect data
N_s=30;
N_q=500;
N_x=30;
xT=zeros(3,N_s+1);
xT[:,1]=[-21.2;8.3;3.0];
uT=zeros(1,N_s+1);
uT[:,1]= -KT*xT[:,1];
for i=1:N_s
    xT[:,i+1]=A*xT[:,i]+B*uT[:,i];
    uT[:,i+1]= -KT*xT[:,i+1]+[0.7*sin(i)];
end
# Train
global Phi=zeros(16,N_s);
global Psi=zeros(1,N_s);
global Q=copy(Q0);
# for k=N_s:-1:1
#     Phi[:,k]=([xT[:,k]' uT[:,k]'] ⊗ [xT[:,k]' uT[:,k]']-[xT[:,k+1]' uT[:,k+1]'] ⊗ [xT[:,k+1]' uT[:,k+1]'])';
#     Psi[:,k]=[xT[:,k]'*Q*xT[:,k]+uT[:,k]'*R*uT[:,k]];
# end
Q_full=[];
push!(Q_full,Q);
H_full=[];
global VarPhi=zeros(9,N_x);
global Omega=zeros(1,N_x);
global Error = zeros(1,N_q);
global Show_Q = zeros(1,N_q);
x=zeros(3,N_x+1);
x[:,1]=[-21.2;8.3;3.0]; # Initial state
u=zeros(1,N_x+1);
for j=1:N_q
    for k=N_s:-1:1
        global Phi[:,k]=([xT[:,k]' uT[:,k]'] ⊗ [xT[:,k]' uT[:,k]']-[xT[:,k+1]' uT[:,k+1]'] ⊗ [xT[:,k+1]' uT[:,k+1]'])';
        global Psi[:,k]=[xT[:,k]'*Q*xT[:,k]+uT[:,k]'*R*uT[:,k]];
    end
    # global vec_H= pinv(Phi*Phi')*Phi*Psi';
    global vec_H= (Phi')\(Psi'); # Using LS to solve
    global H=reshape(vec_H,4,4);
    global Hp=H-[Q zeros(3,1);zeros(1,3) R];
    push!(H_full,H);
    global K_c = reshape(pinv(H[end,end])*H[end,1:end-1],1,3);
    u[:,1]=-K_c*x[:,1];
    for q=1:N_x    
        x[:,q+1]=A*x[:,q]+B*u[:,q];
        u[:,q+1]= -K_c*x[:,q+1];
    end
    global P= [1* Matrix(I, 3, 3) -KT']*H*[1* Matrix(I, 3, 3) -KT']';
    # for q=N_x+1:-1:2
    #     global VarPhi[:,q-1]=(x[:,q]' ⊗ x[:,q]')';
    #     global Omega[:,q-1]=[alpha*[x[:,q-1]' u[:,q-1]']*Hp*[x[:,q-1]' u[:,q-1]']'-alpha*[x[:,q]' u[:,q]']*Hp*[x[:,q]' u[:,q]']']-alpha*[u[:,q]'*R*u[:,q]]+(1-alpha)*[x[:,q]'*Q*x[:,q]];
    # end
    for q=N_x:-1:1
        global VarPhi[:,q]=(x[:,q]' ⊗ x[:,q]')';
        global Omega[:,q]=[alpha*x[:,q]'*P*x[:,q]-alpha*x[:,q+1]'*P*x[:,q+1]]-alpha*[u[:,q]'*R*u[:,q]]+(1-alpha)*[x[:,q]'*Q*x[:,q]];
    end
    global vec_Q= pinv(VarPhi*VarPhi')*VarPhi*Omega';# Using LS to solve
    global Q=reshape(vec_Q,3,3);
    push!(Q_full,Q);
    global Error[:,j]=[norm(KT-K_c)];
    global Show_Q[:,j] = [norm(Q)];
end

# Plot
t=1:1:N_q;
p1=plot(t[:,1],Error',label="|| K_T - K||")
p2=plot(t[:,1],Show_Q',label="||Q||")
plot(p1, p2, layout=(2,1))

# t=collect(1:1:N_q);
# anim = @animate for i = 1:N_q
#     p1=plot(t[1:i],Error'[1:i],label="|| K_T - K||")
#     p2=plot(t[1:i],Show_Q'[1:i],label="||Q||")
#     plot(p1, p2, layout=(2,1))
# end
# gif(anim, "anim_fps15.gif", fps = 15)