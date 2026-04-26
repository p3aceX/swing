package R2;

import D2.AbstractActivityC0029d;
import D2.v;
import N2.j;
import O2.o;
import Y0.n;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Build;
import java.util.HashMap;
import java.util.HashSet;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public class a implements K2.a, L2.a, o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final PackageManager f1708a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public n f1709b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public HashMap f1710c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final HashMap f1711d = new HashMap();

    public a(v vVar) {
        this.f1708a = (PackageManager) vVar.f260b;
        vVar.f261c = this;
    }

    @Override // O2.o
    public final boolean a(int i4, int i5, Intent intent) {
        HashMap map = this.f1711d;
        if (!map.containsKey(Integer.valueOf(i4))) {
            return false;
        }
        ((j) map.remove(Integer.valueOf(i4))).c(i5 == -1 ? intent.getStringExtra("android.intent.extra.PROCESS_TEXT") : null);
        return true;
    }

    @Override // L2.a
    public final void b(n nVar) {
        this.f1709b = nVar;
        ((HashSet) nVar.f2490c).add(this);
    }

    @Override // L2.a
    public final void d() {
        ((HashSet) this.f1709b.f2490c).remove(this);
        this.f1709b = null;
    }

    @Override // L2.a
    public final void e(n nVar) {
        this.f1709b = nVar;
        ((HashSet) nVar.f2490c).add(this);
    }

    @Override // L2.a
    public final void f() {
        ((HashSet) this.f1709b.f2490c).remove(this);
        this.f1709b = null;
    }

    public final void g(String str, String str2, boolean z4, j jVar) {
        if (this.f1709b == null) {
            jVar.a(null, "error", "Plugin not bound to an Activity");
            return;
        }
        HashMap map = this.f1710c;
        if (map == null) {
            jVar.a(null, "error", "Can not process text actions before calling queryTextActions");
            return;
        }
        ResolveInfo resolveInfo = (ResolveInfo) map.get(str);
        if (resolveInfo == null) {
            jVar.a(null, "error", "Text processing activity not found");
            return;
        }
        int iHashCode = jVar.hashCode();
        this.f1711d.put(Integer.valueOf(iHashCode), jVar);
        Intent intent = new Intent();
        ActivityInfo activityInfo = resolveInfo.activityInfo;
        intent.setClassName(activityInfo.packageName, activityInfo.name);
        intent.setAction("android.intent.action.PROCESS_TEXT");
        intent.setType("text/plain");
        intent.putExtra("android.intent.extra.PROCESS_TEXT", str2);
        intent.putExtra("android.intent.extra.PROCESS_TEXT_READONLY", z4);
        ((AbstractActivityC0029d) this.f1709b.f2488a).startActivityForResult(intent, iHashCode);
    }

    public final HashMap h() {
        HashMap map = this.f1710c;
        PackageManager packageManager = this.f1708a;
        if (map == null) {
            this.f1710c = new HashMap();
            Intent type = new Intent().setAction("android.intent.action.PROCESS_TEXT").setType("text/plain");
            for (ResolveInfo resolveInfo : Build.VERSION.SDK_INT >= 33 ? packageManager.queryIntentActivities(type, PackageManager.ResolveInfoFlags.of(0L)) : packageManager.queryIntentActivities(type, 0)) {
                String str = resolveInfo.activityInfo.name;
                resolveInfo.loadLabel(packageManager).toString();
                this.f1710c.put(str, resolveInfo);
            }
        }
        HashMap map2 = new HashMap();
        for (String str2 : this.f1710c.keySet()) {
            map2.put(str2, ((ResolveInfo) this.f1710c.get(str2)).loadLabel(packageManager).toString());
        }
        return map2;
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
    }
}
