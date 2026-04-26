package O;

import android.os.Bundle;
import androidx.lifecycle.EnumC0221g;
import b.C0229f;
import java.util.ArrayList;
import java.util.HashMap;

/* JADX INFO: renamed from: O.v, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0110v implements Y.d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1426a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f1427b;

    public /* synthetic */ C0110v(Object obj, int i4) {
        this.f1426a = i4;
        this.f1427b = obj;
    }

    @Override // Y.d
    public final Bundle a() {
        switch (this.f1426a) {
            case 0:
                AbstractActivityC0114z abstractActivityC0114z = (AbstractActivityC0114z) this.f1427b;
                while (AbstractActivityC0114z.j(((C0113y) abstractActivityC0114z.f1438x.f104b).e)) {
                }
                abstractActivityC0114z.f1439y.e(EnumC0221g.ON_STOP);
                return new Bundle();
            case 1:
                AbstractActivityC0114z abstractActivityC0114z2 = (AbstractActivityC0114z) this.f1427b;
                Bundle bundle = new Bundle();
                C0229f c0229f = abstractActivityC0114z2.f3236p;
                c0229f.getClass();
                HashMap map = c0229f.f3216b;
                bundle.putIntegerArrayList("KEY_COMPONENT_ACTIVITY_REGISTERED_RCS", new ArrayList<>(map.values()));
                bundle.putStringArrayList("KEY_COMPONENT_ACTIVITY_REGISTERED_KEYS", new ArrayList<>(map.keySet()));
                bundle.putStringArrayList("KEY_COMPONENT_ACTIVITY_LAUNCHED_KEYS", new ArrayList<>(c0229f.f3218d));
                bundle.putBundle("KEY_COMPONENT_ACTIVITY_PENDING_RESULT", (Bundle) c0229f.f3220g.clone());
                return bundle;
            default:
                return ((N) this.f1427b).V();
        }
    }
}
