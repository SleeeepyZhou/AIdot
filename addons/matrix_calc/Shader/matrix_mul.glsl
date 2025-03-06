#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) readonly buffer MatA { float A[]; };
layout(set = 0, binding = 1, std430) readonly buffer MatB { float B[]; };
layout(set = 0, binding = 2, std430) writeonly buffer MatC { float C[]; };

layout(set = 0, binding = 3, std430) readonly buffer Matrices {
    int M;
    int N;
    int K;
};

shared float Asub[16][16];
shared float Bsub[16][16];

void main() {
    uint row = gl_GlobalInvocationID.y;
    uint col = gl_GlobalInvocationID.x;

    uint localRow = gl_LocalInvocationID.y;
    uint localCol = gl_LocalInvocationID.x;

    float value = 0.0;

    for (uint t = 0; t < (K + 15) / 16; ++t) {
        if (row < M && t * 16 + localCol < K) {
            Asub[localRow][localCol] = A[row * K + t * 16 + localCol];
        }
        else {
            Asub[localRow][localCol] = 0.0;
        }
        if (col < N && t * 16 + localRow < K) {
            Bsub[localRow][localCol] = B[(t * 16 + localRow) * N + col];
        }
        else {
            Bsub[localRow][localCol] = 0.0;
        }

        barrier();

        
        for (uint k = 0; k < 16; ++k) {
            value += Asub[localRow][k] * Bsub[k][localCol];
        }
        
        barrier();
    }

    if (row < M && col < N) {
        C[row * N + col] = value;
    }
}