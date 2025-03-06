#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) readonly buffer MatA { float A[]; };
layout(set = 0, binding = 1, std430) readonly buffer Scalar { float F[]; };
layout(set = 0, binding = 2, std430) writeonly buffer MatB { float B[]; };

layout(set = 0, binding = 3, std430) readonly buffer Matrices {
    int width;
    int height;
};

void main() {
    uint row = gl_GlobalInvocationID.y;
    uint col = gl_GlobalInvocationID.x;

    if (row < height && col < width) {
        uint index = row * width + col;
        B[index] = A[index] * F[0];
    }
}