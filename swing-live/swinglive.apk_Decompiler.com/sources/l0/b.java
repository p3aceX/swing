package l0;

import I3.l;
import androidx.window.sidecar.SidecarDisplayFeature;

/* JADX INFO: loaded from: classes.dex */
public final class b extends J3.j implements l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final b f5570a = new b(1);

    @Override // I3.l
    /* JADX INFO: renamed from: c, reason: merged with bridge method [inline-methods] */
    public final Boolean invoke(SidecarDisplayFeature sidecarDisplayFeature) {
        J3.i.e(sidecarDisplayFeature, "$this$require");
        boolean z4 = true;
        if (sidecarDisplayFeature.getType() != 1 && sidecarDisplayFeature.getType() != 2) {
            z4 = false;
        }
        return Boolean.valueOf(z4);
    }
}
