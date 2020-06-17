package org.devalot.ialab.torta.inference.util

class TwoSet<A>(private val first: A, private val second: A) {
    init {
        require(first != second)
    }

    fun toPair(): Pair<A, A> = Pair(first, second)

    override fun equals(other: Any?): Boolean =
            this === other || (other is TwoSet<*> && (
                    this.toPair() == other.toPair() || this.toPair() == other.toPair().swap()
                    ))

    override fun hashCode(): Int {
        return first.hashCode() + second.hashCode()
    }
}

private fun <A, B> Pair<A, B>.swap(): Pair<B, A> = Pair(this.second, this.first)