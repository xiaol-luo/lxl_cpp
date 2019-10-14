using UnityEditor;
using UnityEngine;
using Utopia;
using System.IO;

namespace UtopiaEditor
{
    public class HotFixWindow : EditorWindow
    {
        [MenuItem("Tools/HotFixWindow", false, 200)]
        public static void OpenWindow()
        {
            var window = EditorWindow.GetWindow<HotFixWindow>("HotFixWindow");
            window.minSize = new Vector2(480.0f, 480.0f);
            window.autoRepaintOnSceneChange = true;
            window.wantsMouseEnterLeaveWindow = true;
            window.wantsMouseMove = true;
        }
        private void Awake()
        {
            Debug.Log("HotFixWindow::Awake");
        }

        private void OnEnable()
        {
            Debug.Log("HotFixWindow::OnEnable");
        }

        private void OnDisable()
        {
            Debug.Log("HotFixWindow::OnDisable");
        }

        private void Update()
        {
            // Debug.Log("HotFixWindow::Update");
        }
        private void OnGUI()
        {
            // Debug.Log("HotFixWindow::OnGUI");
            this.DrawUI();
        }
        private void OnInspectorUpdate()
        {
            // Debug.Log("HotFixWindow::OnInspectorUpdate");
        }

        private void OnFocus()
        {
            Debug.Log("HotFixWindow::OnFocus");
        }

        private void OnLostFocus()
        {
            Debug.Log("HotFixWindow::OnLostFocus");
        }

        private void OnDestroy()
        {
            Debug.Log("HotFixWindow::OnDestroy");
        }

        private void OnHierarchyChange()
        {
            Debug.Log("HotFixWindow::OnHierarchyChange");
        }
        private void OnProjectChange()
        {
            Debug.Log("HotFixWindow::OnProjectChange");
        }

        // void Test
        void DrawUI()
        {
            EditorGUILayout.BeginVertical(EditorStyles.textArea);

            EditorGUILayout.BeginVertical();

            if (GUILayout.Button("hotfix lua"))
            {
                this.TryHotfixLua();
            }
        }

        void TryHotfixLua()
        {
            if (!Application.isPlaying)
                return;

            
            string luaScriptRoot = Lua.LuaHelp.ScriptRootDir();
            string hotfix_file_path = System.IO.Path.Combine(luaScriptRoot, "main_logic/hotfix/hotfix_logic.lua");
            string content = File.ReadAllText(hotfix_file_path);
            App.ins.lua.DoString(content);
        }
    }
}