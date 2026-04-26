package b;

import O.AbstractActivityC0114z;
import android.content.Intent;
import android.content.IntentSender;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import d.C0321a;
import java.util.ArrayList;
import java.util.HashMap;
import u1.C0690c;
import y0.C0747k;

/* JADX INFO: renamed from: b.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0229f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashMap f3215a = new HashMap();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashMap f3216b = new HashMap();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final HashMap f3217c = new HashMap();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ArrayList f3218d = new ArrayList();
    public final transient HashMap e = new HashMap();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final HashMap f3219f = new HashMap();

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final Bundle f3220g = new Bundle();

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final /* synthetic */ AbstractActivityC0114z f3221h;

    public C0229f(AbstractActivityC0114z abstractActivityC0114z) {
        this.f3221h = abstractActivityC0114z;
    }

    public final boolean a(int i4, int i5, Intent intent) {
        String str = (String) this.f3215a.get(Integer.valueOf(i4));
        if (str == null) {
            return false;
        }
        d.c cVar = (d.c) this.e.get(str);
        if (cVar != null) {
            d.b bVar = cVar.f3877a;
            if (this.f3218d.contains(str)) {
                bVar.k(cVar.f3878b.Q(i5, intent));
                this.f3218d.remove(str);
                return true;
            }
        }
        this.f3219f.remove(str);
        this.f3220g.putParcelable(str, new C0321a(i5, intent));
        return true;
    }

    public final void b(int i4, H0.a aVar, Intent intent) {
        Bundle bundleExtra;
        int i5;
        AbstractActivityC0114z abstractActivityC0114z = this.f3221h;
        C0690c c0690cF = aVar.F(abstractActivityC0114z, intent);
        if (c0690cF != null) {
            new Handler(Looper.getMainLooper()).post(new RunnableC0228e(this, i4, c0690cF, 0));
            return;
        }
        Intent intentN = aVar.n(abstractActivityC0114z, intent);
        if (intentN.getExtras() != null && intentN.getExtras().getClassLoader() == null) {
            intentN.setExtrasClassLoader(abstractActivityC0114z.getClassLoader());
        }
        if (intentN.hasExtra("androidx.activity.result.contract.extra.ACTIVITY_OPTIONS_BUNDLE")) {
            bundleExtra = intentN.getBundleExtra("androidx.activity.result.contract.extra.ACTIVITY_OPTIONS_BUNDLE");
            intentN.removeExtra("androidx.activity.result.contract.extra.ACTIVITY_OPTIONS_BUNDLE");
        } else {
            bundleExtra = null;
        }
        Bundle bundle = bundleExtra;
        if ("androidx.activity.result.contract.action.REQUEST_PERMISSIONS".equals(intentN.getAction())) {
            String[] stringArrayExtra = intentN.getStringArrayExtra("androidx.activity.result.contract.extra.PERMISSIONS");
            if (stringArrayExtra == null) {
                stringArrayExtra = new String[0];
            }
            q.e.a(abstractActivityC0114z, stringArrayExtra, i4);
            return;
        }
        if (!"androidx.activity.result.contract.action.INTENT_SENDER_REQUEST".equals(intentN.getAction())) {
            abstractActivityC0114z.startActivityForResult(intentN, i4, bundle);
            return;
        }
        d.d dVar = (d.d) intentN.getParcelableExtra("androidx.activity.result.contract.extra.INTENT_SENDER_REQUEST");
        try {
            i5 = i4;
            try {
                abstractActivityC0114z.startIntentSenderForResult(dVar.f3879a, i5, dVar.f3880b, dVar.f3881c, dVar.f3882d, 0, bundle);
            } catch (IntentSender.SendIntentException e) {
                e = e;
                new Handler(Looper.getMainLooper()).post(new RunnableC0228e(this, i5, e, 1));
            }
        } catch (IntentSender.SendIntentException e4) {
            e = e4;
            i5 = i4;
        }
    }

    public final C0747k c(String str, H0.a aVar, d.b bVar) {
        int i4;
        HashMap map;
        HashMap map2 = this.f3216b;
        if (((Integer) map2.get(str)) == null) {
            K3.a aVar2 = K3.d.f859a;
            int iNextInt = K3.d.f859a.d().nextInt(2147418112);
            while (true) {
                i4 = iNextInt + 65536;
                map = this.f3215a;
                if (!map.containsKey(Integer.valueOf(i4))) {
                    break;
                }
                K3.a aVar3 = K3.d.f859a;
                iNextInt = K3.d.f859a.d().nextInt(2147418112);
            }
            map.put(Integer.valueOf(i4), str);
            map2.put(str, Integer.valueOf(i4));
        }
        this.e.put(str, new d.c(bVar, aVar));
        HashMap map3 = this.f3219f;
        if (map3.containsKey(str)) {
            Object obj = map3.get(str);
            map3.remove(str);
            bVar.k(obj);
        }
        Bundle bundle = this.f3220g;
        C0321a c0321a = (C0321a) bundle.getParcelable(str);
        if (c0321a != null) {
            bundle.remove(str);
            bVar.k(aVar.Q(c0321a.f3875a, c0321a.f3876b));
        }
        return new C0747k(this, str, aVar);
    }
}
