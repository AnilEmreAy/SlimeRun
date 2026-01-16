using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;


namespace Symphonie.StoreAssets.Editor {
    public class SlimeMaterialGUI : ShaderGUI 
    {
        static Regex groupRegex = new Regex(@"^\s*Group\s*\((?<name>[^\)\,]*)\s*(\,\s*(?<order>\d+))?\s*\)");


        class Group {
            public string Name;
            public int Order = int.MaxValue;
            public List<MaterialProperty> Properties = new List<MaterialProperty>();
        }
        List<Group> CachedPropGroups = new List<Group>();
        int CachedPropertyHash = 0;

        void UpdatePropertyCache(MaterialEditor materialEditor, MaterialProperty[] properties) {
            Dictionary<string, Group> grps = new Dictionary<string, Group>();

            var shader = (materialEditor.target as Material).shader;
            foreach(var p in properties) {
                if(p.propertyFlags.HasFlag(ShaderPropertyFlags.HideInInspector))
                    continue;

                int idx = shader.FindPropertyIndex(p.name);
                var attrs = shader.GetPropertyAttributes(idx);
                bool anyMatch = false;
                foreach(var a in attrs) {                    
                    var m = groupRegex.Match(a);
                    if(!m.Success)
                        continue;
                    string grpName = m.Groups["name"].Value;
                    string order = m.Groups["order"].Value;
                    
                    if(!grps.TryGetValue(grpName, out var grp)){
                        grp = new Group { Name = grpName};
                        grps.Add(grpName, grp);
                    }
                    
                    if(grp.Order == int.MaxValue && !string.IsNullOrEmpty(order)) {                        
                        grp.Order = int.Parse(order);
                    }
                    grp.Properties.Add(p);
                    anyMatch = true;
                }
                if(!anyMatch) {
                    if(!grps.ContainsKey("Misc"))
                        grps.Add("Misc", new Group{ Name = "Misc" });
                    var grp = grps["Misc"];
                    grp.Properties.Add(p);
                }
            }
            CachedPropGroups = grps.Values.ToList();
            CachedPropGroups.Sort((x,y)=>x.Order.CompareTo(y.Order));

            CachedPropertyHash = shader.GetHashCode();
        }


        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {   
            var shader = (materialEditor.target as Material).shader;
            
            if(CachedPropGroups == null || CachedPropertyHash != shader.GetHashCode())
                UpdatePropertyCache(materialEditor, properties);
            
            foreach(var grp in CachedPropGroups) {
                using(new EditorGUILayout.VerticalScope(EditorStyles.helpBox)) {
                    using(new EditorGUILayout.VerticalScope(GUI.skin.box)) {
                        GUILayout.Label(grp.Name, EditorStyles.boldLabel);
                    }

                    foreach(var p in grp.Properties) {
                        materialEditor.ShaderProperty(p, p.displayName);
                    }
                }
                
            }
            
            
        }
    }

}
