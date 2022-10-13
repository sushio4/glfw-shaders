#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <iostream>
#include <string>
#include <filesystem>
#include <vector>
#include <windows.h>
#include "FreeImage.h"
namespace fs = std::filesystem;

#include "ShaderUtil.h"

ShaderUtil shaderUtil;
GLuint resolutionLoc;
std::string v_shader = "vs_shader.glsl";
std::string fs_fname = "Shaders/fs_sinus.glsl";

unsigned int buffer;
const char* version = "v1.0a";
float points[] = {
    //left
    -1.0f, -1.0f,
    //top
    -1.0f, 1.0f,
    //right
    1.0f, -1.0f,
    //BOOM now its a rectangle
    1.0f, 1.0f
    //it used to be a triangle but BOOM
};
int resol[2] = {640, 480};

bool mainBreak = false;

void pos(short C, short R)
{
    COORD xy;
    xy.X = C;
    xy.Y = R;
    SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), xy);
}
void cls()
{
    pos(0, 0);
    for (int j = 0; j < 100; j++)
        std::cout << std::string(100, ' ');
    pos(0, 0);
}

std::string findFile(std::string&& path)
{
    std::vector<std::string>files;
    int index = 0;
    for (const auto& entry : fs::directory_iterator(path))
    {
        files.push_back(std::string(entry.path().string(), path.length()));
        std::cout << ++index << " : " << files[index-1] << std::endl;
    }
    std::cout << "Enter the number of file you want to load:\n> ";
    std::cin >> index;
    if (--index >= files.size())
        return "";
    return path + files[index];
}

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
    resol[0] = width;
    resol[1] = height;
    glProgramUniform2f(shaderUtil.getid(), resolutionLoc, width, height);
}

void key_callback(GLFWwindow* window, int key, int scancode, int action, int mod)
{
    if (key == GLFW_KEY_O && action == GLFW_PRESS && mod == GLFW_MOD_CONTROL)
        mainBreak = true;
    else if (key == GLFW_KEY_S && action == GLFW_PRESS && mod == GLFW_MOD_CONTROL)
    {

        // Convert to FreeImage format & save to file
        BYTE* pixels = new BYTE[3 * resol[0] * resol[1]];
        glReadPixels(0, 0, resol[0], resol[1], GL_BGR, GL_BYTE, pixels);
        FIBITMAP* Image = FreeImage_ConvertFromRawBits(pixels, resol[0], resol[1], 3 * resol[0], 24, 0xFF0000, 0x00FF00, 0x0000FF, false);
        FreeImage_Save(FIF_PNG, Image, "test.png", 0);

        // Free resources
        FreeImage_Unload(Image);
        delete[] pixels;
    }
}

int main(void)
{
    GLFWwindow* window;

    while (true)
    {
        mainBreak = false;
        /* Initialize the library */
        if (!glfwInit())
            return -1;

        while (true)
        {
            cls();
            std::cout << "Suski's Shader Program " << version << "\n-----------------------------\nPress CTRL + O to open file\n-----------------------------\n";
            fs_fname = findFile("Shaders/");
            std::cin.clear();
            if (fs_fname == "")
            {
                std::cout << "Invalid number!\nPress enter to continue...";
                std::cin.get();
                std::cin.get();
            }
            else
                break;
        }
        std::cout << "File: " << fs_fname << std::endl;
        /* Create a windowed mode window and its OpenGL context */
        window = glfwCreateWindow(640, 480, ("SSP " + std::string(version) + " : " + fs_fname).c_str(), NULL, NULL);
        if (!window)
        {
            glfwTerminate();
            return -1;
        }

        /* Make the window's context current */
        glfwMakeContextCurrent(window);
        glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
        glfwSetKeyCallback(window, key_callback);

        //glew
        GLenum err = glewInit();
        if (GLEW_OK != err)
        {
            /* Problem: glewInit failed, something is seriously wrong. */
            std::cout << "Error: " << glewGetErrorString(err) << std::endl;
        }
        std::cout << "\nStatus: Using GLEW " << glewGetString(GLEW_VERSION) << "\n";

        shaderUtil.Load(v_shader, fs_fname);

        resolutionLoc = glGetUniformLocation(shaderUtil.getid(), "u_resolution");
        int width, height;
        glfwGetWindowSize(window, &width, &height);
        glProgramUniform2f(shaderUtil.getid(), resolutionLoc, width, height);

        //create buffer
        glGenBuffers(1, &buffer);

        //bindthe buffer to vertex attributes
        glBindBuffer(GL_ARRAY_BUFFER, buffer);

        //init buffer
        glBufferData(GL_ARRAY_BUFFER, 8 * sizeof(float), points, GL_STATIC_DRAW);

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 2, 0);

        shaderUtil.Use();

        /* Loop until the user closes the window */
        while (!glfwWindowShouldClose(window))
        {
            /* Render here */
            glClear(GL_COLOR_BUFFER_BIT);

            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            /* Swap front and back buffers */
            glfwSwapBuffers(window);

            /* Poll for and process events */
            glfwPollEvents();
            if (mainBreak)
                break;
        }
        if (glfwWindowShouldClose(window))
        {
            shaderUtil.Delete();
            glfwTerminate();
            return 0;
        }

        shaderUtil.Delete();
        glfwTerminate();
    }
}