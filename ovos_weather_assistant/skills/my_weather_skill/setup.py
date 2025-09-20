from setuptools import setup, find_packages

setup(
    name="ovos-skill-my-weather",
    version="1.0.0",
    description="OVOS skill: weather and time in Turkish",
    author="Kaan Lütfi Taşkın",
    packages=["my_weather_skill"],
    include_package_data=True,
    package_data={
        "my_weather_skill": [
            "manifest.json",
            "locale/tr-tr/**/*.intent",
            "locale/**/*.intent",
        ]
    },
    install_requires=[
        "requests",
        "ovos-bus-client",
        "ovos-workshop",
        "ovos-utils",
    ],
    entry_points={
        "ovos.plugin.skill": [
            "my_weather_skill=my_weather_skill:WeatherSkill",
        ]
    },
    
    classifiers=[
        "Programming Language :: Python :: 3",
        
    ],
)
