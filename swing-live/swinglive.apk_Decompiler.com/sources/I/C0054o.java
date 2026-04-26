package I;

import java.io.File;
import java.io.IOException;
import java.util.LinkedHashSet;

/* JADX INFO: renamed from: I.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0054o extends J3.j implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f710a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Q f711b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ C0054o(Q q4, int i4) {
        super(0);
        this.f710a = i4;
        this.f711b = q4;
    }

    @Override // I3.a
    public final Object a() throws IOException {
        switch (this.f710a) {
            case 0:
                return ((Z) this.f711b.f605p.a()).f633b;
            default:
                W w4 = this.f711b.f597a;
                File canonicalFile = ((File) w4.f620b.a()).getCanonicalFile();
                synchronized (W.f618d) {
                    String absolutePath = canonicalFile.getAbsolutePath();
                    LinkedHashSet linkedHashSet = W.f617c;
                    if (linkedHashSet.contains(absolutePath)) {
                        throw new IllegalStateException(("There are multiple DataStores active for the same file: " + absolutePath + ". You should either maintain your DataStore as a singleton or confirm that there is no two DataStore's active on the same file (by confirming that the scope is cancelled).").toString());
                    }
                    J3.i.d(absolutePath, "path");
                    linkedHashSet.add(absolutePath);
                }
                return new Z(canonicalFile, (l0) w4.f619a.invoke(canonicalFile), new V(canonicalFile, 0));
        }
    }
}
