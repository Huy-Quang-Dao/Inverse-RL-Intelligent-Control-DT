# Thư viện
using LinearAlgebra
using Plots
using Kronecker
# Mô hình
A = [-1 0.9 1.3;0.8 -1.1 -0.7;0 0 -1];
B=[0.0,0.0,1.0][:,:];
C=[[1.0] [0.0] [2.0]];
# Thông số chuyên gia để thu thập dữ liệu
QT=Matrix(Diagonal([15.0,10.0,10.0]));
RT=[2.0][:,:];
KT=[1.3413 -1.5032 -2.4570];
PT=[71.1153 -61.7194 -65.5975;-61.7194 79.0522 71.1584;-65.5975 71.1584 89.3458];
HT = [QT+A'*PT*A A'*PT*B;B'*PT*A RT+B'*PT*B];
# Thông số của người học
Q0 = Matrix(Diagonal([1.0,1.0,1.0]));
# Q = Vector{Float64}[];
# Q[1]=Q0;
R=[1.0][:,:];
alpha=1.0;
# Thu thập dữ liệu
N_s=100;
N_q=400;
N_x=100;
xT=zeros(3,N_s+1);
xT[:,1]=[10;10;10];
uT=zeros(1,N_s+1);
uT[:,1]= -KT*xT[:,1];
for i=1:N_s
    xT[:,i+1]=A*xT[:,i]+B*uT[:,i];
    uT[:,i+1]= -KT*xT[:,i+1];
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
x=zeros(3,N_x+1);
x[:,1]=[2;2;2];
u=zeros(1,N_x+1);
for j=1:1
    for k=N_s:-1:1
        global Phi[:,k]=([xT[:,k]' uT[:,k]'] ⊗ [xT[:,k]' uT[:,k]']-[xT[:,k+1]' uT[:,k+1]'] ⊗ [xT[:,k+1]' uT[:,k+1]'])';
        global Psi[:,k]=[xT[:,k]'*Q*xT[:,k]+uT[:,k]'*R*uT[:,k]];
    end
    # global vec_H= pinv(Phi*Phi')*Phi*Psi';
    global vec_H= (Phi')\(Psi');
    global H=reshape(vec_H,4,4);
    global Hp=H-[Q zeros(3,1);zeros(1,3) R];
    push!(H_full,H);
    global K_c = reshape(pinv(H[end,end])*H[end,1:end-1],1,3);
    u[:,1]=-K_c*x[:,1];
    for q=1:N_x    
        x[:,q+1]=A*x[:,q]+B*u[:,q];
        u[:,q+1]= -K_c*x[:,q+1];
    end
    for q=N_x+1:-1:2
        global VarPhi[:,q-1]=(x[:,q]' ⊗ x[:,q]')';
        global Omega[:,q-1]=[alpha*[x[:,q-1]' u[:,q-1]']*Hp*[x[:,q-1]' u[:,q-1]']'-alpha*[x[:,q]' u[:,q]']*Hp*[x[:,q]' u[:,q]']']-alpha*[u[:,q]'*R*u[:,q]]+(1-alpha)*[x[:,q]'*Q*x[:,q]];
    end
    # global vec_Q= pinv(VarPhi*VarPhi')*VarPhi*Omega';
    # global Q=reshape(vec_Q,3,3);
    # push!(Q_full,Q);
end

