package l0;

import android.graphics.Rect;
import androidx.window.sidecar.SidecarDeviceState;
import androidx.window.sidecar.SidecarDisplayFeature;
import androidx.window.sidecar.SidecarWindowLayoutInfo;
import f0.C0399a;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public final class f {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ int f5574b = 0;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f5575a;

    public f() {
        B1.a.o(3, "verificationMode");
        this.f5575a = 3;
    }

    public static boolean a(SidecarDisplayFeature sidecarDisplayFeature, SidecarDisplayFeature sidecarDisplayFeature2) {
        if (J3.i.a(sidecarDisplayFeature, sidecarDisplayFeature2)) {
            return true;
        }
        if (sidecarDisplayFeature == null || sidecarDisplayFeature2 == null || sidecarDisplayFeature.getType() != sidecarDisplayFeature2.getType()) {
            return false;
        }
        return J3.i.a(sidecarDisplayFeature.getRect(), sidecarDisplayFeature2.getRect());
    }

    public static boolean b(List list, List list2) {
        if (list == list2) {
            return true;
        }
        if (list.size() == list2.size()) {
            int size = list.size();
            for (int i4 = 0; i4 < size; i4++) {
                if (a((SidecarDisplayFeature) list.get(i4), (SidecarDisplayFeature) list2.get(i4))) {
                }
            }
            return true;
        }
        return false;
    }

    public final i0.j c(SidecarWindowLayoutInfo sidecarWindowLayoutInfo, SidecarDeviceState sidecarDeviceState) {
        if (sidecarWindowLayoutInfo == null) {
            return new i0.j(p.f6784a);
        }
        SidecarDeviceState sidecarDeviceState2 = new SidecarDeviceState();
        AbstractC0521a.d(sidecarDeviceState2, AbstractC0521a.b(sidecarDeviceState));
        return new i0.j(d(AbstractC0521a.c(sidecarWindowLayoutInfo), sidecarDeviceState2));
    }

    public final ArrayList d(List list, SidecarDeviceState sidecarDeviceState) {
        ArrayList arrayList = new ArrayList();
        Iterator it = list.iterator();
        while (it.hasNext()) {
            i0.c cVarE = e((SidecarDisplayFeature) it.next(), sidecarDeviceState);
            if (cVarE != null) {
                arrayList.add(cVarE);
            }
        }
        return arrayList;
    }

    public final i0.c e(SidecarDisplayFeature sidecarDisplayFeature, SidecarDeviceState sidecarDeviceState) {
        i0.b bVar;
        i0.b bVar2;
        J3.i.e(sidecarDisplayFeature, "feature");
        C0399a c0399a = C0399a.f4264a;
        int i4 = this.f5575a;
        B1.a.o(i4, "verificationMode");
        SidecarDisplayFeature sidecarDisplayFeature2 = (SidecarDisplayFeature) new f0.g(sidecarDisplayFeature, i4, c0399a).J("Type must be either TYPE_FOLD or TYPE_HINGE", b.f5570a).J("Feature bounds must not be 0", c.f5571a).J("TYPE_FOLD must have 0 area", d.f5572a).J("Feature be pinned to either left or top", e.f5573a).d();
        if (sidecarDisplayFeature2 == null) {
            return null;
        }
        int type = sidecarDisplayFeature2.getType();
        if (type == 1) {
            bVar = i0.b.f4461m;
        } else {
            if (type != 2) {
                return null;
            }
            bVar = i0.b.f4462n;
        }
        int iB = AbstractC0521a.b(sidecarDeviceState);
        if (iB == 0 || iB == 1) {
            return null;
        }
        if (iB != 2) {
            bVar2 = i0.b.e;
            if (iB != 3 && iB == 4) {
                return null;
            }
        } else {
            bVar2 = i0.b.f4460f;
        }
        Rect rect = sidecarDisplayFeature.getRect();
        J3.i.d(rect, "feature.rect");
        return new i0.c(new f0.b(rect), bVar, bVar2);
    }
}
