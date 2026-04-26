package T2;

import A.C0003c;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Build;
import com.google.firebase.FirebaseCommonRegistrar;
import u1.C0688a;

/* JADX INFO: renamed from: T2.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0164i implements l1.d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ Object f1973a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f1974b;

    public /* synthetic */ C0164i(Object obj, Object obj2) {
        this.f1973a = obj;
        this.f1974b = obj2;
    }

    public void a(String str, String str2) {
        ((C0166k) this.f1973a).f1977a = false;
        ((C0162g) this.f1974b).a(str, str2);
    }

    @Override // l1.d
    public Object e(R0.k kVar) {
        String strValueOf;
        Context context = (Context) kVar.a(Context.class);
        switch (((C0003c) this.f1974b).f41a) {
            case 14:
                ApplicationInfo applicationInfo = context.getApplicationInfo();
                strValueOf = applicationInfo == null ? "" : String.valueOf(applicationInfo.targetSdkVersion);
                break;
            case 15:
                ApplicationInfo applicationInfo2 = context.getApplicationInfo();
                strValueOf = applicationInfo2 == null ? "" : String.valueOf(applicationInfo2.minSdkVersion);
                break;
            case 16:
                strValueOf = !context.getPackageManager().hasSystemFeature("android.hardware.type.television") ? !context.getPackageManager().hasSystemFeature("android.hardware.type.watch") ? !context.getPackageManager().hasSystemFeature("android.hardware.type.automotive") ? (Build.VERSION.SDK_INT >= 26 && context.getPackageManager().hasSystemFeature("android.hardware.type.embedded")) ? "embedded" : "" : "auto" : "watch" : "tv";
                break;
            default:
                String installerPackageName = context.getPackageManager().getInstallerPackageName(context.getPackageName());
                strValueOf = installerPackageName == null ? "" : FirebaseCommonRegistrar.a(installerPackageName);
                break;
        }
        return new C0688a((String) this.f1973a, strValueOf);
    }
}
