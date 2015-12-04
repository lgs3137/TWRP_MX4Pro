package lgs3137.twrpmx4pro;

import android.app.Activity;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class MainActivity extends Activity implements OnClickListener {
    public Process process;

    Button installButton, rebootButton, uninstallButton;

    Toast info;

    public static boolean upgradeRootPermission(String pkgCodePath) {
        Process process = null;
        DataOutputStream os = null;
        try {
            String cmd = "chmod 755 " + pkgCodePath;
            process = Runtime.getRuntime().exec("su");
            os = new DataOutputStream(process.getOutputStream());
            os.writeBytes(cmd + "\n");
            os.writeBytes("exit\n");
            os.flush();
            process.waitFor();
        } catch (Exception e) {
            return false;
        } finally {
            try {
                if (os != null) {
                    os.close();
                }
                assert process != null;
                process.destroy();
            } catch (Exception ignored) {
            }
        }
        return true;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        installButton = (Button) findViewById(R.id.install_button);
        installButton.setOnClickListener(this);

        rebootButton = (Button) findViewById(R.id.reboot_recovery);
        rebootButton.setOnClickListener(this);

        uninstallButton = (Button) findViewById(R.id.uninstall_recovery);
        uninstallButton.setOnClickListener(this);
    }

    @Override
    public void onClick(View clickedButton) {
        upgradeRootPermission(getPackageCodePath());
        switch (clickedButton.getId()) {
            case R.id.install_button:
                installRecovery();
                info = Toast.makeText(getApplicationContext(), "安装TWRP", Toast.LENGTH_LONG);
                info.show();
                break;
            case R.id.reboot_recovery:
                rebootRecovery();
                info = Toast.makeText(getApplicationContext(), "重启TWRP", Toast.LENGTH_LONG);
                info.show();
                break;
            case R.id.uninstall_recovery:
                uninstallRecovery();
                info = Toast.makeText(getApplicationContext(), "卸载TWRP", Toast.LENGTH_LONG);
                info.show();
                break;
        }
    }

    public void installRecovery() {
        try {
            process = Runtime.getRuntime().exec("su");
            DataOutputStream install = new DataOutputStream(
                    process.getOutputStream());
            install.writeBytes("mount -o rw,remount /system\n");
            AssetManager myAsset = getAssets();
            String[] files;
            try {
                files = myAsset.list("twrp");
                for (String filename : files) {
                    InputStream in;
                    in = myAsset.open("twrp/" + filename);
                    OutputStream out = new FileOutputStream("/data/data/lgs3137.twrpmx4pro/" + filename);
                    int read;
                    byte[] buffer = new byte[1024];
                    while ((read = in.read(buffer)) != -1) {
                        out.write(buffer, 0, read);
                    }
                    out.close();
                }
                install.writeBytes("cp -rf /data/data/lgs3137.twrpmx4pro/busybox /system/xbin\n");
                install.writeBytes("chmod 775 /system/xbin/busybox\n");
                install.writeBytes("rm -rf /system/twrp\n");
                install.writeBytes("cp -rf /data/data/lgs3137.twrpmx4pro/install-recovery.sh /system/bin\n");
                install.writeBytes("cp -rf /data/data/lgs3137.twrpmx4pro/install-recovery.sh /system/etc\n");
                install.writeBytes("chmod 775 /system/bin/install-recovery.sh\n");
                install.writeBytes("chmod 775 /system/etc/install-recovery.sh\n");
                install.writeBytes("busybox tar -xv -C /system -f /data/data/lgs3137.twrpmx4pro/twrp.tar.xz\n");
                install.writeBytes("sleep 8000\n");
                install.flush();
                install.close();
            } catch (NullPointerException e) {
                Log.e("ListAsset", "Install：" + e.getMessage());
            }
        } catch (IOException e) {
            Log.e("ShellLinux", "Install：" + e.getMessage());
        }
    }

    public void rebootRecovery() {
        try {
            process = Runtime.getRuntime().exec("su");
            DataOutputStream reboot = new DataOutputStream(
                    process.getOutputStream());
            reboot.writeBytes("touch /cache/recovery/command\n");
            reboot.writeBytes("reboot\n");
        } catch (Exception e) {
            Log.e("Reboot", e.getMessage());
        }
    }

    public void uninstallRecovery() {
        try {
            process = Runtime.getRuntime().exec("su");
            DataOutputStream uninstall = new DataOutputStream(
                    process.getOutputStream());
            uninstall.writeBytes("mount -o rw,remount /system\n");
            uninstall.writeBytes("rm -rf /system/twrp\n");
            uninstall.writeBytes("sync\n");
            uninstall.flush();
            uninstall.close();
        } catch (Exception e) {
            Log.e("Uninstall", e.getMessage());
        }
    }
}
