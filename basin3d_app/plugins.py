# Register BASIN-3D Plugins
# Django plugins will not register the plugins unless they are loaded here
from basin3d.plugins import usgs
print(f"Registered {usgs}")