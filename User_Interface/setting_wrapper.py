import mmap
import os
import struct

class MemoryMonitor:
    def __init__(self, base_addr):
        self.base_addr = base_addr
        self.memory_fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
        self.last_msb = 1  # Initialize MSB to 1

    def __del__(self):
        os.close(self.memory_fd)

    def write_value(self, value):
        with mmap.mmap(self.memory_fd, length=32 // 8, flags=mmap.MAP_SHARED,
                       prot=mmap.PROT_WRITE | mmap.PROT_READ,
                       offset=self.base_addr) as gpio_vptr:
            gpio_vptr[:] = struct.pack('I', value)
            result = struct.unpack('I', gpio_vptr[:4])[0]
            print("Written value: 0x{:08X}, Read value: 0x{:08X}".format(value, result))

    def set_repetition(self, value):
        self._write_setting(value, 0b111111, 0)

    def set_samples(self, value):
        self._write_setting(value, 0b111110, 0)

    def set_hops(self, value):
        self._write_setting(value, 0b111101, 0)

    def trigger_settings(self, cpu_trig):
        msb = self.last_msb  # Use the current MSB value
        encoded_value = (msb << 31) | (cpu_trig << 24)
        self.write_value(encoded_value)
        self.last_msb = 0 if msb == 1 else 1  # Toggle the MSB

    def _write_setting(self, value, setting_type, cpu_trig):
        msb = self.last_msb  # Use the current MSB value
        encoded_value = (msb << 31) | (setting_type << 25) | (cpu_trig << 24) | (value & 0xFFFFFF)
        self.write_value(encoded_value)
        self.last_msb = 0 if msb == 1 else 1  # Toggle the MSB

if __name__ == '__main__':
    monitor = MemoryMonitor(base_addr=0x7FFFF000)

    # Example usage:
    # Set repetitions to 2
    monitor.set_repetition(value=2)

    # Set samples to 4095
    monitor.set_samples(value=4095)

    # Set hops to 1
    monitor.set_hops(value=1)

    # Trigger settings independently
    monitor.trigger_settings(cpu_trig=1)

