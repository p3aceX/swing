package d1;

import com.google.crypto.tink.shaded.protobuf.InterfaceC0318x;

/* JADX INFO: loaded from: classes.dex */
public enum O implements InterfaceC0318x {
    UNKNOWN_HASH(0),
    SHA1(1),
    SHA384(2),
    SHA256(3),
    SHA512(4),
    SHA224(5),
    UNRECOGNIZED(-1);


    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3901a;

    O(int i4) {
        this.f3901a = i4;
    }

    public final int a() {
        if (this != UNRECOGNIZED) {
            return this.f3901a;
        }
        throw new IllegalArgumentException("Can't get the number of an unknown enum value.");
    }
}
