using InterfaceProcessor;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.ComponentModel.Composition.Hosting;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Viasat.PTE.CCS.IVI.Interop.Core.DriverAdapters;

namespace ConsumeProcessor
{
    class AssemblyProcessor
    {
        [Import(typeof(IProcessor))]
        public IProcessor CurrentProcessor { get; set; }



        static void Main(string[] args)
        {

            IList<string> directories = new List<string>();

            List<string> gacFolders = new List<string>() {
                    "GAC", "GAC_32", "GAC_64", "GAC_MSIL",
                    "NativeImages_v2.0.50727_32",
                    "NativeImages_v2.0.50727_64",
                    "NativeImages_v4.0.30319_32",
                    "NativeImages_v4.0.30319_64"
                };


            string Net2Path = Path.Combine(Environment.GetEnvironmentVariable("windir"), "assembly");

            foreach (string folder in gacFolders)
            {
                string path = Path.Combine(Net2Path, folder);

                if (Directory.Exists(path))
                {
                    string[] assemblyFolders = Directory.GetDirectories(path);
                    foreach (string assemblyFolder in assemblyFolders)
                    {
                        directories.Add(assemblyFolder);
                    }
                }
            }

            string Net4Path = Path.Combine(Environment.GetEnvironmentVariable("windir"), @"Microsoft.NET\assembly");

            foreach (string folder in gacFolders)
            {
                string path = Path.Combine(Net4Path, folder);

                if (Directory.Exists(path))
                {
                    string[] assemblyFolders = Directory.GetDirectories(path);
                    foreach (string assemblyFolder in assemblyFolders)
                    {
                        directories.Add(assemblyFolder);
                    }
                }
            }

            IList<string> assemblies = new List<string>();
            foreach (string directory in directories)
            {
                /* DirectoryInfo dInfo = new DirectoryInfo(directory);
                 FileInfo[] files = dInfo.GetFiles("*.dll", SearchOption.AllDirectories);

                 if (files != null)
                 {
                     foreach (FileInfo file in files)
                     {

                     }
                 } */

                string pattern = @"^sly_";

                var matches = Directory
                  .GetFiles(@"D:\mypath")
                  .Where(path => Regex.IsMatch(Path.GetFileName(path), pattern));
            }

                /* IList<string> assemblies = new List<string>();

                 foreach (string directory in directories)
                 {
                     DirectoryInfo dInfo = new DirectoryInfo(directory);
                     FileInfo[] files = dInfo.GetFiles("*.dll", SearchOption.AllDirectories);

                     if (files != null)
                     {
                         foreach (FileInfo file in files)
                         {
                             Assembly assembly = null;
                             Type[] assemblyTypes = null;
                             try
                             {
                                 assembly = Assembly.LoadFrom(file.FullName);
                                 assemblyTypes = assembly.GetTypes();
                             }
                             catch
                             { }

                             if (assembly != null && assemblyTypes != null)
                             {
                                 if (assemblyTypes.Any(typeof(Viasat.PTE.CCS.IVI.Interop.Core.SessionFactoryBase).IsAssignableFrom))
                                     assemblies.Add(file.FullName);

                             }
                         }
                     }

                 } */




                Assembly asm = Assembly.LoadFrom("SerialProcess.dll");

            var catalog = new AssemblyCatalog(asm);


            var processor = new AssemblyProcessor();
            var container = new CompositionContainer(catalog);

            container.ComposeParts(processor);

            if (processor.CurrentProcessor != null)
            {
                IProcessor currentProcessor = processor.CurrentProcessor;
                currentProcessor.Process();

            }
        }

        

    }
}
