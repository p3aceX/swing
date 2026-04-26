package O;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import d.C0321a;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import u1.C0690c;
import x3.AbstractC0730j;

/* JADX INFO: loaded from: classes.dex */
public final class I extends H0.a {

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final /* synthetic */ int f1217i;

    public /* synthetic */ I(int i4) {
        this.f1217i = i4;
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // H0.a
    public C0690c F(AbstractActivityC0114z abstractActivityC0114z, Intent intent) {
        switch (this.f1217i) {
            case 1:
                String[] strArr = (String[]) intent;
                J3.i.e(strArr, "input");
                if (strArr.length == 0) {
                    return new C0690c(x3.q.f6785a, 23);
                }
                for (String str : strArr) {
                    if (r.h.checkSelfPermission(abstractActivityC0114z, str) != 0) {
                        return null;
                    }
                }
                int iC0 = x3.s.c0(strArr.length);
                if (iC0 < 16) {
                    iC0 = 16;
                }
                LinkedHashMap linkedHashMap = new LinkedHashMap(iC0);
                for (String str2 : strArr) {
                    linkedHashMap.put(str2, Boolean.TRUE);
                }
                return new C0690c(linkedHashMap, 23);
            default:
                return super.F(abstractActivityC0114z, intent);
        }
    }

    @Override // H0.a
    public final Object Q(int i4, Intent intent) {
        switch (this.f1217i) {
            case 0:
                return new C0321a(i4, intent);
            case 1:
                x3.q qVar = x3.q.f6785a;
                if (i4 != -1 || intent == null) {
                    return qVar;
                }
                String[] stringArrayExtra = intent.getStringArrayExtra("androidx.activity.result.contract.extra.PERMISSIONS");
                int[] intArrayExtra = intent.getIntArrayExtra("androidx.activity.result.contract.extra.PERMISSION_GRANT_RESULTS");
                if (intArrayExtra == null || stringArrayExtra == null) {
                    return qVar;
                }
                ArrayList arrayList = new ArrayList(intArrayExtra.length);
                for (int i5 : intArrayExtra) {
                    arrayList.add(Boolean.valueOf(i5 == 0));
                }
                ArrayList arrayList2 = new ArrayList();
                for (String str : stringArrayExtra) {
                    if (str != null) {
                        arrayList2.add(str);
                    }
                }
                Iterator it = arrayList2.iterator();
                Iterator it2 = arrayList.iterator();
                ArrayList arrayList3 = new ArrayList(Math.min(AbstractC0730j.V(arrayList2), AbstractC0730j.V(arrayList)));
                while (it.hasNext() && it2.hasNext()) {
                    arrayList3.add(new w3.c(it.next(), it2.next()));
                }
                return x3.s.f0(arrayList3);
            default:
                return new C0321a(i4, intent);
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // H0.a
    public final Intent n(AbstractActivityC0114z abstractActivityC0114z, Intent intent) {
        Bundle bundleExtra;
        switch (this.f1217i) {
            case 0:
                d.d dVar = (d.d) intent;
                Intent intent2 = new Intent("androidx.activity.result.contract.action.INTENT_SENDER_REQUEST");
                Intent intent3 = dVar.f3880b;
                if (intent3 != null && (bundleExtra = intent3.getBundleExtra("androidx.activity.result.contract.extra.ACTIVITY_OPTIONS_BUNDLE")) != null) {
                    intent2.putExtra("androidx.activity.result.contract.extra.ACTIVITY_OPTIONS_BUNDLE", bundleExtra);
                    intent3.removeExtra("androidx.activity.result.contract.extra.ACTIVITY_OPTIONS_BUNDLE");
                    if (intent3.getBooleanExtra("androidx.fragment.extra.ACTIVITY_OPTIONS_BUNDLE", false)) {
                        dVar = new d.d(dVar.f3879a, null, dVar.f3881c, dVar.f3882d);
                    }
                }
                intent2.putExtra("androidx.activity.result.contract.extra.INTENT_SENDER_REQUEST", dVar);
                if (N.J(2)) {
                    Log.v("FragmentManager", "CreateIntent created the following intent: " + intent2);
                }
                return intent2;
            case 1:
                String[] strArr = (String[]) intent;
                J3.i.e(strArr, "input");
                Intent intentPutExtra = new Intent("androidx.activity.result.contract.action.REQUEST_PERMISSIONS").putExtra("androidx.activity.result.contract.extra.PERMISSIONS", strArr);
                J3.i.d(intentPutExtra, "Intent(ACTION_REQUEST_PE…EXTRA_PERMISSIONS, input)");
                return intentPutExtra;
            default:
                J3.i.e(intent, "input");
                return intent;
        }
    }
}
