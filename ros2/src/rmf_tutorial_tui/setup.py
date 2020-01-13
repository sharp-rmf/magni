from setuptools import setup

package_name = 'rmf_tutorial_tui'

setup(
    name=package_name,
    version='0.0.0',
    packages=[package_name],
    package_data={'rmf_tutorial_tui': ['*.sh']},
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='bhan',
    maintainer_email='cnboonhan94@gmail.com',
    description='TODO: Package description',
    license='TODO: License declaration',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            "tui = rmf_tutorial_tui.tui:main"
        ],
    },
)
