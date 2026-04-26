package B1;

import J3.i;
import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes.dex */
public final class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ByteBuffer f115a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final b f116b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final c f117c;

    public d(ByteBuffer byteBuffer, b bVar, c cVar) {
        this.f115a = byteBuffer;
        this.f116b = bVar;
        this.f117c = cVar;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof d)) {
            return false;
        }
        d dVar = (d) obj;
        return i.a(this.f115a, dVar.f115a) && i.a(this.f116b, dVar.f116b) && this.f117c == dVar.f117c;
    }

    public final int hashCode() {
        return this.f117c.hashCode() + ((this.f116b.hashCode() + (this.f115a.hashCode() * 31)) * 31);
    }

    public final String toString() {
        return "MediaFrame(data=" + this.f115a + ", info=" + this.f116b + ", type=" + this.f117c + ")";
    }
}
