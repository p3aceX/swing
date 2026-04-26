package l3;

import java.io.ObjectInputStream;
import java.io.ObjectStreamClass;
import java.util.LinkedHashSet;

/* JADX INFO: loaded from: classes.dex */
public final class N extends ObjectInputStream {
    @Override // java.io.ObjectInputStream
    public final Class resolveClass(ObjectStreamClass objectStreamClass) throws ClassNotFoundException {
        String[] strArr = {"java.util.Arrays$ArrayList", "java.util.ArrayList", "java.lang.String", "[Ljava.lang.String;"};
        LinkedHashSet linkedHashSet = new LinkedHashSet(x3.s.c0(4));
        for (int i4 = 0; i4 < 4; i4++) {
            linkedHashSet.add(strArr[i4]);
        }
        String name = objectStreamClass != null ? objectStreamClass.getName() : null;
        if (name == null || linkedHashSet.contains(name)) {
            return super.resolveClass(objectStreamClass);
        }
        throw new ClassNotFoundException(objectStreamClass.getName());
    }
}
