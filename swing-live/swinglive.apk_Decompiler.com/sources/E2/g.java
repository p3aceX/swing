package E2;

import D2.AbstractActivityC0029d;
import io.flutter.plugin.platform.q;
import java.util.ArrayList;
import java.util.List;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f376a = new ArrayList();

    public g(AbstractActivityC0029d abstractActivityC0029d, String[] strArr) {
        I2.e eVar = (I2.e) C0747k.N().f6831b;
        if (eVar.f761a) {
            return;
        }
        eVar.c(abstractActivityC0029d.getApplicationContext());
        eVar.a(abstractActivityC0029d.getApplicationContext(), strArr);
    }

    public final c a(f fVar) {
        c cVar;
        AbstractActivityC0029d abstractActivityC0029d = fVar.f371a;
        F2.a aVar = fVar.f372b;
        String str = fVar.f373c;
        List<String> list = fVar.f374d;
        q qVar = new q();
        boolean z4 = fVar.e;
        boolean z5 = fVar.f375f;
        if (aVar == null) {
            I2.e eVar = (I2.e) C0747k.N().f6831b;
            if (!eVar.f761a) {
                throw new AssertionError("DartEntrypoints can only be created once a FlutterEngine is created.");
            }
            aVar = new F2.a(eVar.f764d.f754b, "main");
        }
        F2.a aVar2 = aVar;
        ArrayList arrayList = this.f376a;
        if (arrayList.size() == 0) {
            cVar = new c(abstractActivityC0029d, null, qVar, z4, z5);
            if (str != null) {
                ((C0747k) cVar.f348i.f104b).O("setInitialRoute", str, null);
            }
            cVar.f343c.a(aVar2, list);
        } else {
            c cVar2 = (c) arrayList.get(0);
            if (!cVar2.f341a.isAttached()) {
                throw new IllegalStateException("Spawn can only be called on a fully constructed FlutterEngine");
            }
            long j4 = c.f339y;
            cVar = new c(abstractActivityC0029d, cVar2.f341a.spawn(aVar2.f442c, aVar2.f441b, str, list, j4), qVar, z4, z5);
        }
        arrayList.add(cVar);
        cVar.v.add(new e(this, cVar));
        return cVar;
    }
}
