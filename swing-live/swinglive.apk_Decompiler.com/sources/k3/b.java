package K3;

import J3.i;
import java.util.Random;

/* JADX INFO: loaded from: classes.dex */
public final class b extends a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final J0.b f858b = new J0.b(1);

    @Override // K3.a
    public final Random d() {
        Object obj = this.f858b.get();
        i.d(obj, "get(...)");
        return (Random) obj;
    }
}
