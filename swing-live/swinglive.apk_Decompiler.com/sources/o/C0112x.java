package O;

import android.os.Bundle;
import b.C0229f;
import java.util.ArrayList;
import java.util.HashMap;

/* JADX INFO: renamed from: O.x, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0112x {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1430a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ AbstractActivityC0114z f1431b;

    public /* synthetic */ C0112x(AbstractActivityC0114z abstractActivityC0114z, int i4) {
        this.f1430a = i4;
        this.f1431b = abstractActivityC0114z;
    }

    public final void a() {
        switch (this.f1430a) {
            case 0:
                C0113y c0113y = (C0113y) this.f1431b.f1438x.f104b;
                c0113y.e.b(c0113y, c0113y, null);
                break;
            default:
                AbstractActivityC0114z abstractActivityC0114z = this.f1431b;
                Bundle bundleA = ((Y.e) abstractActivityC0114z.e.f2464c).a("android:support:activity-result");
                if (bundleA != null) {
                    C0229f c0229f = abstractActivityC0114z.f3236p;
                    c0229f.getClass();
                    ArrayList<Integer> integerArrayList = bundleA.getIntegerArrayList("KEY_COMPONENT_ACTIVITY_REGISTERED_RCS");
                    ArrayList<String> stringArrayList = bundleA.getStringArrayList("KEY_COMPONENT_ACTIVITY_REGISTERED_KEYS");
                    if (stringArrayList != null && integerArrayList != null) {
                        c0229f.f3218d = bundleA.getStringArrayList("KEY_COMPONENT_ACTIVITY_LAUNCHED_KEYS");
                        Bundle bundle = bundleA.getBundle("KEY_COMPONENT_ACTIVITY_PENDING_RESULT");
                        Bundle bundle2 = c0229f.f3220g;
                        bundle2.putAll(bundle);
                        for (int i4 = 0; i4 < stringArrayList.size(); i4++) {
                            String str = stringArrayList.get(i4);
                            HashMap map = c0229f.f3216b;
                            boolean zContainsKey = map.containsKey(str);
                            HashMap map2 = c0229f.f3215a;
                            if (zContainsKey) {
                                Integer num = (Integer) map.remove(str);
                                if (!bundle2.containsKey(str)) {
                                    map2.remove(num);
                                }
                            }
                            Integer num2 = integerArrayList.get(i4);
                            num2.intValue();
                            String str2 = stringArrayList.get(i4);
                            map2.put(num2, str2);
                            map.put(str2, num2);
                        }
                        break;
                    }
                }
                break;
        }
    }
}
