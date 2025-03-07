// Copyright Danny Arends 2021
// Distributed under the GNU General Public License, Version 3
// See accompanying file LICENSE.txt or copy at https://www.gnu.org/licenses/gpl-3.0.en.html

import core.stdc.string : memcpy;

import calderad, buffer, wavefront;

struct Vertex {
  float[3] pos = [0.0f, 0.0f, 0.0f];
  float[2] texCoord = [0.0f, 1.0f];
  float[4] color = [1.0f, 1.0f, 1.0f, 1.0f];
  float[3] normal = [0.0f, 1.0f, 0.0f];

  static VkVertexInputBindingDescription getBindingDescription() {
    VkVertexInputBindingDescription bindingDescription = {
      binding: 0,
      stride: Vertex.sizeof,
      inputRate: VK_VERTEX_INPUT_RATE_VERTEX
    };

    return bindingDescription;
  }
  
  static VkVertexInputAttributeDescription[4] getAttributeDescriptions() {
    VkVertexInputAttributeDescription[4] attributeDescriptions = [{
      binding: 0,
      location: 0,
      format: VK_FORMAT_R32G32B32_SFLOAT,
      offset: Vertex.pos.offsetof
    },{
      binding: 0,
      location: 1,
      format: VK_FORMAT_R32G32B32A32_SFLOAT,
      offset: Vertex.color.offsetof
    },{
    binding: 0,
      location: 2,
      format: VK_FORMAT_R32G32B32_SFLOAT,
      offset: Vertex.normal.offsetof
    },{
      binding: 0,
      location: 3,
      format: VK_FORMAT_R32G32_SFLOAT,
      offset: Vertex.texCoord.offsetof
    }];

    return attributeDescriptions;
  }
};

void createVertexBuffers(ref App app) {
  for(size_t j = 0; j < app.geometry.length; j++) {
    uint bufferSize = cast(uint)(app.geometry[j].vertices[0].sizeof * app.geometry[j].vertices.length);

    VkBuffer stagingBuffer;
    VkDeviceMemory stagingBufferMemory;

    app.createBuffer(bufferSize, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT, &stagingBuffer, &stagingBufferMemory);

    void* data;
    vkMapMemory(app.device, stagingBufferMemory, 0, bufferSize, 0, &data);
    memcpy(data, cast(void*)app.geometry[j].vertices, cast(size_t) bufferSize);
    vkUnmapMemory(app.device, stagingBufferMemory);

    app.createBuffer(bufferSize, VK_BUFFER_USAGE_TRANSFER_DST_BIT | VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, &app.geometry[j].vertexBuffer, &app.geometry[j].vertexBufferMemory);
    app.copyBuffer(stagingBuffer, app.geometry[j].vertexBuffer, bufferSize);

    vkDestroyBuffer(app.device, stagingBuffer, null);
    vkFreeMemory(app.device, stagingBufferMemory, null);
    toStdout("Vertex buffer holding %d bytes created", bufferSize);
  }
}

void createIndexBuffers(ref App app) {
  for(size_t j = 0; j < app.geometry.length; j++) {
    uint bufferSize = cast(uint)(app.geometry[j].indices[0].sizeof * app.geometry[j].indices.length);

    VkBuffer stagingBuffer;
    VkDeviceMemory stagingBufferMemory;
    app.createBuffer(bufferSize, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT, &stagingBuffer, &stagingBufferMemory);

    void* data;
    vkMapMemory(app.device, stagingBufferMemory, 0, bufferSize, 0, &data);
    memcpy(data, cast(void*)app.geometry[j].indices, cast(size_t) bufferSize);
    vkUnmapMemory(app.device, stagingBufferMemory);

    app.createBuffer(bufferSize, VK_BUFFER_USAGE_TRANSFER_DST_BIT | VK_BUFFER_USAGE_INDEX_BUFFER_BIT, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, &app.geometry[j].indexBuffer, &app.geometry[j].indexBufferMemory);
    app.copyBuffer(stagingBuffer, app.geometry[j].indexBuffer, bufferSize);

    vkDestroyBuffer(app.device, stagingBuffer, null);
    vkFreeMemory(app.device, stagingBufferMemory, null);
    toStdout("Index buffer holding %d bytes created", bufferSize);
  }
}
